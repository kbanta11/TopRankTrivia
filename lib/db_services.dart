import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'dart:math';
import 'models.dart';

class DBService {
  Firestore _db = Firestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<String> signInWithGoogle() async {
    GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn().catchError((error) {
      print('Google Sign-in Error: $error');
    });
    GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
    AuthCredential credential = GoogleAuthProvider.getCredential(idToken: googleSignInAuthentication.idToken, accessToken: googleSignInAuthentication.accessToken);
    AuthResult authResult = await _auth.signInWithCredential(credential).catchError((error) {
      print('Sign in error: $error');
    });
    final FirebaseUser user = authResult.user;
    print('logged in user: ${user.email}');
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    await createOrUpdateUserDoc(user);

    return 'Success';
  }

  void signOutGoogle() async {
    await _googleSignIn.signOut();
  }

  Future<String> facebookLogin() async {
    FacebookLogin _fbLogin = new FacebookLogin();
    FacebookLoginResult result = await _fbLogin.logIn(['email','public_profile']).catchError((err) => print('Error: $err'));
    print('result: ${result.errorMessage}');
    if(result.status == FacebookLoginStatus.loggedIn) {
      AuthCredential credential = FacebookAuthProvider.getCredential(accessToken: result.accessToken.token);
      print('Auth Credential: $credential');
      AuthResult authResult = await _auth.signInWithCredential(credential).catchError((error) => print('Firebase FB Error: $error'));
      final FirebaseUser user = authResult.user;
      print('FirebaseUser: $user');
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);

      await createOrUpdateUserDoc(user);
      return 'Success';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    if(await _googleSignIn.isSignedIn()) {
      print('signing out google');
      signOutGoogle();
    }
  }

  Future<void> createOrUpdateUserDoc(FirebaseUser user) async {
    DocumentReference docRef = _db.collection('users').document(user.uid);
    if(await docRef.get().then((value) => !value.exists)) {
      //create new user doc
      _db.runTransaction((transaction) {
        transaction.set(docRef, {
          'userId': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'dateCreated': DateTime.now(),
          'lastLoggedIn': DateTime.now(),
          'photoUrl': user.photoUrl,
          'coins': 1000,
          'bars': 3,
          'laddersEntered': 0,
          'laddersPlaced': 0,
          'laddersWon': 0,
        }).catchError((err) {
          print('Error: $err');
        });
        return;
      });
    } else {
      //update user doc last logged in
      _db.runTransaction((transaction) {
        transaction.update(docRef, {
          'email': user.email,
          'displayName': user.displayName,
          'lastLoggedIn': DateTime.now(),
          'photoUrl': user.photoUrl,
        });
        return;
      });
    }
    print('creating user doc completed: ${docRef.documentID}');
  }

  Stream<User> streamUserDoc(FirebaseUser user) {
    return _db.collection('users').document(user.uid).snapshots().map((snap) => User.fromFirestore(snap));
  }

  Stream<List<Message>> streamUserMessages(User user) {
    return _db.collection('users').document(user.userId).collection('messages').orderBy('datesent', descending: true).snapshots().map((QuerySnapshot querySnap) {
      print('QuerySnapshot: $querySnap/${querySnap.documents.length}');
      return querySnap.documents.map((DocumentSnapshot docSnap) => Message.fromFirestore(docSnap)).toList();
    });
  }

  markMessageRead(Message message, User user, {bool value}) async {
    DocumentReference messageRef = _db.collection('users').document(user.userId).collection('messages').document(message.messageId);
    await _db.runTransaction((t) {
      return t.update(messageRef, {'is_read': value != null ? value : !message.isRead});
    });
  }

  Stream<List<Ladder>> streamLadders({String filter, String userId}) {
    Query query = _db.collection('ladders').where('end_date', isGreaterThanOrEqualTo: DateTime.now());
    if(filter == 'Upcoming') {
      query = _db.collection('ladders').where('start_date', isGreaterThanOrEqualTo: DateTime.now());
    }
    if(filter == 'Complete') {
      query = _db.collection('ladders').where('end_date', isLessThan: DateTime.now());
    }
    if(filter == 'My Ladders' && userId != null) {
      query = _db.collection('ladders').where('players', arrayContains: userId);
    }
    return query.getDocuments().asStream().map((QuerySnapshot querySnap) {
      return querySnap.documents.map((doc) => Ladder.fromFirestore(doc)).toList();
    });
  }

  Stream<List<Question>> streamUnverifiedQuestions() {
    return _db.collection('questions').where('is_verified', isEqualTo: null).snapshots().map((snap) => snap.documents.map((doc) => Question.fromFirestore(doc)).toList()).handleError((error) => print('Error getting ladders: $error'));
  }

  Stream<List<Question>> streamAllQuestions() {
    return _db.collection('questions').snapshots().map((snap) => snap.documents.map((doc) => Question.fromFirestore(doc)).toList());
  }
  
  Stream<List<Game>> streamGames({Ladder ladder}) {
    return _db.collection('games').where('ladder_id', isEqualTo: ladder.id).snapshots().map((qs) => qs.documents.map((snap) => Game.fromFirestore(snap)).toList());
  }

  Stream<Game> streamGame(String ladderId, String userId) {
    return _db.collection('games').where('ladder_id', isEqualTo: ladderId).where('user_id', isEqualTo: userId).snapshots().map((snap) => snap.documents.map((doc) => Game.fromFirestore(doc)).first);
  }

  Stream<List<HeadToHeadGame>> streamHeadToHeadGames(User user) {
    return _db.collection('head-to-head').where('players', arrayContains: user.userId).orderBy('datestarted', descending: true).snapshots().map((snap) => snap.documents.map((doc) {
      return HeadToHeadGame.fromFirestore(doc);
    }).toList());
  }

  Stream<HeadToHeadGame> streamHeadToHeadGame(String gameId) {
    return _db.collection('head-to-head').document(gameId).snapshots().map((snap) {
      print('Streaming game');
      HeadToHeadGame game = HeadToHeadGame.fromFirestore(snap);
      print('Streaming game: ${snap.documentID}/$game');
      return game;
    });
  }

  Future<HeadToHeadGame> getHeadToHeadGame(User user, int fee) async {
    bool isAvailableGames = false;
    HeadToHeadGame game;
    //Get existing games for this entry value
    List<HeadToHeadGame> existingGames = await _db.collection('head-to-head').where('entry_fee', isEqualTo: fee).where('game_finished', isEqualTo: false).orderBy('datestarted').getDocuments().then((snap) {
      return snap.documents.map((doc) {
        return HeadToHeadGame.fromFirestore(doc);
      }).toList();
    });
    print('Number of existing games: ${existingGames == null ? '0' : existingGames.length}');
    //Filter out games this player is already in and games with 2 players already (need to check more than just player list, in case game is in progress and already has two players)
    if(existingGames != null && existingGames.length > 0){
      existingGames.removeWhere((e) => e.players.contains(user.userId) || (e.player1 != null && e.player2 != null));
      if(existingGames.length > 0)
        isAvailableGames = true;
      print('Number of games from other users: ${existingGames.length}');
    }
    if(isAvailableGames) {
      //If there are available games to be joined, join an existing game
      print('There are existing games, add user to oldest available unfinished game as player 2!');
      game = existingGames.first;
      WriteBatch batch = _db.batch();
      //Add fields for player 2 to game
      DocumentReference gameRef = _db.collection('head-to-head').document(game.id);
      game.players.add(user.userId);
      game.player2 = user.userId;
      game.player2Name = user.getDisplayName();
      game.player2Score = 0;
      game.player2Bet = 0;
      game.player2Streak = 1;
      game.player2Finished = false;

      batch.updateData(gameRef, {
        'players': game.players,
        'player2': game.player2,
        'player2_name': game.player2Name,
        'player2_score': game.player2Score,
        'player2_bet': game.player2Bet,
        'player2_streak': game.player2Streak,
        'player2_finished': game.player2Finished
      });
      //Update user doc to deduct entry fee from coins
      DocumentReference userReference = _db.collection('users').document(user.userId);
      batch.updateData(userReference, {
        'coins': user.coins - game.entryFee,
        'num_head_to_head': user.numHeadToHead + 1,
      });
      await batch.commit();
      await game.getQuestions();
    } else {
      //if not, create a new game and wait for opponent after completing
      //Get document reference for new game
      DocumentReference gameRef = _db.collection('head-to-head').document();
      //Get list of 15 questions
      List<Question> allQuestions = await _db.collection('questions').where('is_verified', isEqualTo: true).getDocuments().then((snap) {
        return snap.documents.map((doc) => Question.fromFirestore(doc)).toList();
      });
      print('Number of questions: ${allQuestions.length}');
      List<Question> gameQuestions = List<Question>();
      while(gameQuestions.length < 16) {
        int randomQuestionIndex = Random().nextInt(allQuestions.length);
        Question newGameQuestion = allQuestions[randomQuestionIndex];
        gameQuestions.add(newGameQuestion);
        allQuestions.remove(newGameQuestion);
      }
      print('Game Question List: $gameQuestions');
      //add order to questions
      gameQuestions = gameQuestions.asMap().entries.map((entry) {
        Question question = entry.value;
        int index = entry.key;
        question.order = index;
        if(index == 15) {
          question.bonus = true;
        } else {
          question.bonus = false;
        }
        return question;
      }).toList();

      //Get bonus question
      Question bonusQuestion = allQuestions[Random().nextInt(allQuestions.length)];

      //Create game object
      WriteBatch batch = _db.batch();
      //Add user to new game and save references
      game = new HeadToHeadGame(
        id: gameRef.documentID,
        entryFee: fee,
        dateStarted: DateTime.now(),
        players: [user.userId],
        gameFinished: false,
        questions: gameQuestions,
        player1: user.userId,
        player1Name: user.getDisplayName(),
        player1Bet: 0,
        player1Score: 0,
        player1Streak: 1,
        player1Finished: false,
      );
      batch.setData(gameRef, {
        'id': game.id,
        'entry_fee': game.entryFee,
        'datestarted': game.dateStarted,
        'players': game.players,
        'game_finished': game.gameFinished,
        'player1': game.player1,
        'player1_name': game.player1Name,
        'player1_score': game.player1Score,
        'player1_bet': game.player1Bet,
        'player1_streak': game.player1Streak,
        'player1_finished': game.player1Finished,
      });
      //Add all game questions to subcollection of gameref
      game.questions.forEach((Question question) {
        DocumentReference questionRef = gameRef.collection('questions').document(question.id);
        batch.setData(questionRef, {
          'question_id': question.id,
          'order': question.order,
          'difficulty': question.difficulty,
          'category': question.category,
          'answer_counts': question.answerCounts,
          'type': question.type,
          'question': question.question,
          'bonus': question.bonus,
          'correct_answer': question.answers.where((ans) => ans.isCorrect).first.value,
          'incorrect_answers': question.answers.where((ans) => !ans.isCorrect).map((ans) => ans.value).toList(),
        });
      });

      //Update user doc to reflect cost of entry
      DocumentReference userRef = _db.collection('users').document(user.userId);
      int currentCoins = await userRef.get().then((snap) => snap.data['coins']);
      int newCoins = currentCoins - fee;
      int currentHeadToHeadGamesCount = await userRef.get().then((snap) => snap.data['num_head_to_head']);
      batch.updateData(userRef, {
        'coins': newCoins,
        'num_head_to_head': currentHeadToHeadGamesCount != null && currentHeadToHeadGamesCount > 0 ? currentHeadToHeadGamesCount + 1 : 1,
      });
      await batch.commit();
    }
    //start game
    return game;
  }
  
  Future<List<Question>> getGameQuestions(String gameId) async {
    return await _db.collection('head-to-head').document(gameId).collection('questions').orderBy('order').getDocuments().then((snap) {
      return snap.documents.map((doc) => Question.fromFirestore(doc)).toList();
    });
  }

  Future<Question> getQuestion(User user) async {
    List<Question> questionList = await _db.collection('questions').where('is_verified', isEqualTo: true).getDocuments().then((QuerySnapshot querySnap) => querySnap.documents.map((doc) => Question.fromFirestore(doc)).toList());
    List<String> recentQuestionIds = user.recentQuestions != null ? user.recentQuestions.keys.toList() : null;
    if(recentQuestionIds != null) {
      questionList = questionList.where((Question q) => !recentQuestionIds.contains(q.id)).toList();
      print('Removing following question ids: $recentQuestionIds');
    }
    int randomNum = Random().nextInt(questionList.length);
    Question newQuestion = questionList[randomNum];
    if(user.recentQuestions == null) {
      user.recentQuestions = {newQuestion.id: 100};
    } else {
      if(user.recentQuestions.length >= 100) {
        user.recentQuestions.removeWhere((k, v) => v <= 1);
        user.recentQuestions = user.recentQuestions.map((k, v,) => MapEntry(k, v - 1));
        user.recentQuestions.addAll({newQuestion.id: 100});
      } else {
        user.recentQuestions = user.recentQuestions.map((k, v) => MapEntry(k, v - 1));
        user.recentQuestions.addAll({newQuestion.id: 100});
      }
    }
    print('User recent questions: ${user.recentQuestions}');
    await _db.runTransaction((transaction) async {
      DocumentReference userRef = _db.collection('users').document(user.userId);
      transaction.update(userRef, {'recent_questions': user.recentQuestions});
    });
    return newQuestion;
  }

  Future<Ladder> createNewLadder({String createdBy, String title, String prize, DateTime startDate, DateTime endDate, String type, int entryFee, int numLives, int respawnTime}) async {
    DocumentReference ladderRef = _db.collection('ladders').document();
    await _db.runTransaction((transaction) {
      return transaction.set(ladderRef, {
        'created_by': createdBy,
        'created_datetime': DateTime.now(),
        'title': title,
        'prize': prize,
        'start_date': startDate,
        'end_date': endDate,
        'type': type,
        'entry_fee': entryFee,
        'respawn_minutes': respawnTime,
        'lives': numLives,
        'is_paid_out': false,
      });
    });
    return ladderRef.get().then((value) => Ladder.fromFirestore(value));
  }

  void createMultipleLadders() async {
    List<Ladder> laddersToAdd = new List<Ladder>();
    DateTime today = DateTime.now();
    DateTime tomorrowStart = DateTime(today.add(Duration(days: 1)).year, today.add(Duration(days: 1)).month, today.add(Duration(days: 1)).day);
    DateTime tomorrowEnd = DateTime(today.add(Duration(days: 2)).year, today.add(Duration(days: 2)).month, today.add(Duration(days: 2)).day);
    //Add daily ladders -
    laddersToAdd.add(Ladder(startDate: tomorrowStart, endDate: tomorrowEnd, entryFee: 100, type: 'coins', numLives: 25, respawnTime: Duration(minutes: 0), title: 'Daily 100 (Instant Respawn)'));
    laddersToAdd.add(Ladder(startDate: tomorrowStart, endDate: tomorrowEnd, entryFee: 100, type: 'coins', numLives: -1, respawnTime: Duration(minutes: 1), title: 'Daily 100 (Unlimited Lives)'));
    laddersToAdd.add(Ladder(startDate: tomorrowStart, endDate: tomorrowEnd, entryFee: 500, type: 'coins', numLives: 25, respawnTime: Duration(minutes: 0), title: 'Daily 500 (Instant Respawn)'));
    laddersToAdd.add(Ladder(startDate: tomorrowStart, endDate: tomorrowEnd, entryFee: 500, type: 'coins', numLives: -1, respawnTime: Duration(minutes: 2), title: 'Daily 500 (Unlimited Lives)'));
    laddersToAdd.add(Ladder(startDate: tomorrowStart, endDate: tomorrowEnd, entryFee: 1000, type: 'coins', numLives: -1, respawnTime: Duration(minutes: 2), title: 'Daily 1000 (Unlimited Lives)'));
    if(today.weekday == 7) {

    }
    print('$today/$tomorrowStart/$tomorrowEnd/Day: ${tomorrowEnd.weekday}');

    WriteBatch batch = _db.batch();
    laddersToAdd.forEach((element) {
      DocumentReference doc = _db.collection('ladders').document();
      batch.setData(doc, {
        'created_by': 'Automation',
        'created_datetime': DateTime.now(),
        'title': element.title,
        'prize': element.prize,
        'start_date': element.startDate,
        'end_date': element.endDate,
        'type': element.type,
        'entry_fee': element.entryFee,
        'respawn_minutes': element.respawnTime.inMinutes,
        'lives': element.numLives,
        'is_paid_out': false,
      });
      print('${element.title}/Entry Fee: ${element.entryFee} ${element.type}/Number of Lives: ${element.numLives}/Respawn Time: ${element.respawnTime.inMinutes}/Start Date: ${element.startDate}/End Date: ${element.endDate}');
    });
    await batch.commit();
  }

  Future<Game> createGame({Ladder ladder, User user, String type}) async {
    //make sure user doesn't have game
    bool hasGame = await _db.collection('games').where('user_id', isEqualTo: user.userId).where('ladder_id', isEqualTo: ladder.id).getDocuments().then((querySnap) {
      print('getting games');
      return querySnap.documents.length > 0;
    });
    //Create game doc
    print(hasGame);
    if(!hasGame) {
      print('doesnt have game');
      DocumentReference docRef = _db.collection('games').document();
      WriteBatch batch = _db.batch();
      batch.setData(docRef, {
        'id': docRef.documentID,
        'ladder_id': ladder.id,
        'user_id': user.userId,
        'user_displayname': user.displayName,
        'total_score': 0,
        'streak': 0,
        'high_streak': 0,
        'max_lives': ladder.numLives,
        'lives_remaining': ladder.numLives,
        'is_alive': true,
        'entry_time': DateTime.now(),
      });
      //Deduct entry fee from user total
      DocumentReference userDoc = _db.collection('users').document(user.userId);
      int currentCoins = await userDoc.get().then((snap) => snap.data['coins']);
      int currentBars = await userDoc.get().then((snap) => snap.data['bars']);
      int currentLaddersEntered = await userDoc.get().then((snap) => snap.data['laddersEntered']);
      if(type == 'coins')
        currentCoins = currentCoins - ladder.entryFee;
      if(type == 'bars')
        currentBars = currentBars - ladder.entryFee;
      batch.updateData(userDoc, {
        'coins': currentCoins,
        'bars': currentBars,
        'laddersEntered': currentLaddersEntered + 1,
      });
      //Add to number of games on ladder
      DocumentReference ladderDoc = _db.collection('ladders').document(ladder.id);
      int numGames = await ladderDoc.get().then((value) => value.data['num_games']);
      List players = await ladderDoc.get().then((value) => value.data['players']);
      if(numGames == null)
        numGames = 1;
      else
        numGames = numGames + 1;

      if(players == null)
        players = [user.userId];
      else
        players.add(user.userId);
      batch.updateData(ladderDoc, {'num_games': numGames, 'players': players});
      await batch.commit();
      return docRef.get().then((snap) => Game.fromFirestore(snap));
    }
    return null;
  }

  Future<void> answerQuestion(Answer ans, Game game, Question question) async {
    print('${game.id}');
    WriteBatch batch = _db.batch();
    DocumentReference gameRef = _db.collection('games').document(game.id);
    int currentScore = await gameRef.get().then((snap) => snap.data['total_score']);
    int streak = await gameRef.get().then((snap) => snap.data['streak']);
    int livesLeft = await gameRef.get().then((snap) => snap.data['lives_remaining']);
    int newScore = currentScore;
    int highStreak = game.highStreak;
    bool isAlive = true;
    if(ans != null && ans.isCorrect){
      if(streak == null)
        streak = 1;
      else
        streak = streak + 1;

      //check if streak is a new high streak
      if(streak > game.highStreak)
        highStreak = streak;

      //update score with new score for question
      int questionScore;
      int multiplier = 1;
      if(streak < 5) {
        multiplier = 1;
      } else if (streak == 50) {
        multiplier = 100;
      } else if (streak.remainder(5) == 0) {
        multiplier = streak;
      } else if (streak < 10) {
        multiplier = 2;
      } else if (streak < 15) {
        multiplier = 4;
      } else if (streak < 20) {
        multiplier = 8;
      } else if (streak < 25) {
        multiplier = 12;
      } else if (streak < 30) {
        multiplier = 16;
      } else if (streak < 35) {
        multiplier = 20;
      } else if (streak < 40) {
        multiplier = 24;
      } else if (streak < 45) {
        multiplier = 28;
      } else if (streak < 50) {
        multiplier = 32;
      }
      questionScore = multiplier * streak;
      print('Score: $questionScore');
      newScore = currentScore + questionScore;
    } else {
      livesLeft = livesLeft - 1;
      isAlive = false;
      streak = 0;
    }
    batch.updateData(gameRef, {
      'total_score': newScore,
      'streak': streak,
      'high_streak': highStreak,
      'is_alive': isAlive,
      'lives_remaining': livesLeft,
      'last_question_time': DateTime.now(),
    });

    if(question != null) {
      DocumentReference questionRef = _db.collection('questions').document(question.id);
      int timesAnswered = await questionRef.get().then((value) => value.data['times_answered']);
      Map answerCounts = await questionRef.get().then((value) => value.data['answer_counts']);
      if(timesAnswered == null) {
        timesAnswered = 1;
      } else {
        timesAnswered = timesAnswered + 1;
      }
      if(ans != null) {
        if(answerCounts == null) {
          answerCounts = {ans.value: 1};
        } else {
          int answerCnt = answerCounts[ans.value];
          if(answerCnt == null) {
            answerCnt = 1;
          } else {
            answerCnt = answerCnt + 1;
          }
          answerCounts[ans.value] = answerCnt;
        }
      }
      batch.updateData(questionRef, {'times_answered': timesAnswered, 'answer_counts': answerCounts});
    }
    await batch.commit();
    return;
  }

  Future<void> answerQuestionHeadToHead(Answer ans, HeadToHeadGame game, Question question, User user, {bool isBonus}) async {
    print('${game.id}');
    WriteBatch batch = _db.batch();
    DocumentReference gameRef = _db.collection('head-to-head').document(game.id);
    int currentScore;
    int streak;
    int betAmount;
    await gameRef.get().then((snap) {
      currentScore = game.player1 == user.userId ? snap.data['player1_score'] : snap.data['player2_score'];
      streak = game.player1 == user.userId ? snap.data['player1_streak'] : snap.data['player2_streak'];
      betAmount = game.player1 == user.userId ? snap.data['player1_bet'] : snap.data['player2_bet'];
    });
    int newScore;
    int newStreak;
    //Check if answer was correct, if so add score for user and increment streak
    if(ans != null && ans.isCorrect) {
      newScore = question.bonus ? currentScore + (2*betAmount) : currentScore + streak;
      newStreak = streak + 1;
    } else {
      //if not set streak back to 1
      newScore = currentScore;
      newStreak = 1;
    }
    Map<String, dynamic> gameData = {
      'player${game.player1 == user.userId ? '1' : '2'}_score': newScore,
      'player${game.player1 == user.userId ? '1' : '2'}_streak': newStreak,
    };
    if(question.bonus) {
      if(game.player1 == user.userId) {
        gameData.addAll({'player1_finished': true});
      } else {
        gameData.addAll({'player2_finished': true});
      }
    }
    batch.updateData(gameRef, gameData);

    //Mark question as answered for this user
    if(question != null) {
      //Update question for game
      DocumentReference gameQuestionReference = gameRef.collection('questions').document(question.id);
      Map<String, dynamic> gameQData = Map<String, dynamic>();
      if(game.player1 == user.userId) {
        gameQData['player1_correct'] = ans == null ? false : ans.isCorrect;
      } else {
        gameQData['player2_correct'] = ans == null ? false: ans.isCorrect;
      }
      if(question.playersAnswered == null) {
        gameQData['players_answered'] = [user.userId];
      } else {
        question.playersAnswered.add(user.userId);
        gameQData['players_answered'] = question.playersAnswered;
      }
      batch.updateData(gameQuestionReference, gameQData);

      //Update question stats for question overall
      DocumentReference questionRef = _db.collection('questions').document(question.id);
      int timesAnswered = await questionRef.get().then((value) => value.data['times_answered']);
      Map answerCounts = await questionRef.get().then((value) => value.data['answer_counts']);
      if(timesAnswered == null) {
        timesAnswered = 1;
      } else {
        timesAnswered = timesAnswered + 1;
      }
      if(ans != null) {
        if(answerCounts == null) {
          answerCounts = {ans.value: 1};
        } else {
          int answerCnt = answerCounts[ans.value];
          if(answerCnt == null) {
            answerCnt = 1;
          } else {
            answerCnt = answerCnt + 1;
          }
          answerCounts[ans.value] = answerCnt;
        }
      }
      batch.updateData(questionRef, {'times_answered': timesAnswered, 'answer_counts': answerCounts});
    }
    await batch.commit();
    await DBService().endHeadToHeadGame(game);
    return;
  }

  Future<void> makeBonusBetHeadToHead(User user, HeadToHeadGame game, int betAmount) async {
    print('User ${user.userId} is betting $betAmount points on the bonus of game ${game.id}');
    DocumentReference gameRef = _db.collection('head-to-head').document(game.id);
    Map<String, dynamic> gameData = Map<String, dynamic>();
    if(user.userId == game.player1) {
      //process for player 1
      gameData['player1_bet'] = betAmount;
      gameData['player1_score'] = game.player1Score - betAmount;
    } else {
      //process for player 2
      gameData['player2_bet'] = betAmount;
      gameData['player2_score'] = game.player2Score - betAmount;
    }
    await _db.runTransaction((transaction) {
      return transaction.update(gameRef, gameData);
    });
    return null;
  }

  Future<void> endHeadToHeadGame(HeadToHeadGame game) async {
    DocumentReference gameRef = _db.collection('head-to-head').document(game.id);
    HeadToHeadGame updatedGame = await gameRef.get().then((snap) => HeadToHeadGame.fromFirestore(snap));
    WriteBatch batch = _db.batch();
    //check if game is finished by both players
    if(updatedGame.player1 != null && updatedGame.player2 != null && updatedGame.player1Finished && updatedGame.player2Finished) {
      print('Processing end of game: ${game.id}');
      //process end of game, update game to mark finished and set winner
      batch.updateData(gameRef, {
        'game_finished': true,
        'winner': updatedGame.player1Score == updatedGame.player2Score ? 'Tie' : updatedGame.player1Score > updatedGame.player2Score ? updatedGame.player1 : updatedGame.player2,
      });

      //pay out winning user
      if(updatedGame.player1Score == updatedGame.player2Score) {
        //Tie - pay each player back their entry fee
        //Player 1
        DocumentReference player1Ref = _db.collection('users').document(updatedGame.player1);
        User player1 = await player1Ref.get().then((snap) => User.fromFirestore(snap));
        batch.updateData(player1Ref, {
          'coins': player1.coins + updatedGame.entryFee,
        });
        //Player 2
        DocumentReference player2Ref = _db.collection('users').document(updatedGame.player2);
        User player2 = await player2Ref.get().then((snap) => User.fromFirestore(snap));
        batch.updateData(player2Ref, {
          'coins': player2.coins + updatedGame.entryFee,
        });
      } else if (updatedGame.player1Score > updatedGame.player2Score) {
        //Player 1 wins, payout player 1
        DocumentReference player1Ref = _db.collection('users').document(updatedGame.player1);
        User player1 = await player1Ref.get().then((snap) => User.fromFirestore(snap));
        batch.updateData(player1Ref, {
          'coins': player1.coins + (updatedGame.entryFee * 2),
        });
      } else {
        //player 2 wins, payout player 2
        DocumentReference player2Ref = _db.collection('users').document(updatedGame.player2);
        User player2 = await player2Ref.get().then((snap) => User.fromFirestore(snap));
        batch.updateData(player2Ref, {
          'coins': player2.coins + (updatedGame.entryFee * 2),
        });
      }

      //send message to both players with results
      DocumentReference player1MessageRef = _db.collection('users').document(updatedGame.player1).collection('messages').document();
      DocumentReference player2MessageRef = _db.collection('users').document(updatedGame.player2).collection('messages').document();
      if(updatedGame.player1Score == updatedGame.player2Score) {
        //Send tie message to both players
        batch.setData(player1MessageRef, {
          'datesent': DateTime.now(),
          'is_read': false,
          'game_id': updatedGame.id,
          'message_subject': 'What?!? A Tie??',
          'message': 'You\'re Head to Head game with ${updatedGame.player2Name} ended in a tie! You both scored ${game.player1Score} points. You have received your entry fee of ${updatedGame.entryFee} coins back.'
        });
        batch.setData(player2MessageRef, {
          'datesent': DateTime.now(),
          'is_read': false,
          'game_id': updatedGame.id,
          'message_subject': 'What?!? A Tie??',
          'message': 'You\'re Head to Head game with ${updatedGame.player1Name} ended in a tie! You both scored ${game.player2Score} points. You have received your entry fee of ${updatedGame.entryFee} coins back.'
        });
      } else if (updatedGame.player1Score > updatedGame.player2Score) {
        //Send winning congratulations to player 1 and condolences to player 2
        batch.setData(player1MessageRef, {
          'datesent': DateTime.now(),
          'is_read': false,
          'game_id': updatedGame.id,
          'message_subject': 'Victory! Head to Head Winner',
          'message': 'You beat ${updatedGame.player2Name} in a Head to Head game. You outscored your opponent ${updatedGame.player1Score} to ${updatedGame.player2Score}. You won ${updatedGame.entryFee * 2} coins!'
        });
        batch.setData(player2MessageRef, {
          'datesent': DateTime.now(),
          'is_read': false,
          'game_id': updatedGame.id,
          'message_subject': 'You Were Defeated!',
          'message': 'You were beaten by ${updatedGame.player1Name} in a Head to Head game. You were outscored by your opponent ${updatedGame.player1Score} to ${updatedGame.player2Score}. You lost ${updatedGame.entryFee} coins!'
        });
      } else {
        //Send winning congratulations to player 2 and condolences to player 1
        batch.setData(player2MessageRef, {
          'datesent': DateTime.now(),
          'is_read': false,
          'game_id': updatedGame.id,
          'message_subject': 'Victory! Head to Head Winner',
          'message': 'You beat ${updatedGame.player1Name} in a Head to Head game. You outscored your opponent ${updatedGame.player2Score} to ${updatedGame.player1Score}. You won ${updatedGame.entryFee * 2} coins!'
        });
        batch.setData(player1MessageRef, {
          'datesent': DateTime.now(),
          'is_read': false,
          'game_id': updatedGame.id,
          'message_subject': 'You Were Defeated!',
          'message': 'You were beaten by ${updatedGame.player2Name} in a Head to Head game. You were outscored by your opponent ${updatedGame.player2Score} to ${updatedGame.player1Score}. You lost ${updatedGame.entryFee} coins!'
        });
      }
      batch.commit();
    }
    return;
  }

  Future<void> buyBars(int numBars, int cost, User buyer) async {
    DocumentReference user = _db.collection('users').document(buyer.userId);
    int _bars = await user.get().then((value) => value.data['bars']);
    int _coins = await user.get().then((value) => value.data['coins']);
    if(_coins >= cost) {
      _coins = _coins - cost;
      _bars = _bars + numBars;
      await _db.runTransaction((transaction) => transaction.update(user, {'bars': _bars, 'coins': _coins}));
    }
  }

  void rewardCoins(User user, int amount) async {
    DocumentReference userDoc = _db.collection('users').document(user.userId);
    int coins = await userDoc.get().then((snap) => snap.data['coins']);
    coins = coins + amount;
    await _db.runTransaction((transaction) => transaction.update(userDoc, {'coins': coins}));
    return;
  }

  Future<void> updateQuestion(Question question) async {
    DocumentReference q = _db.collection('questions').document(question.id);
    return await _db.runTransaction((transaction) => transaction.update(q, question.toMap()));
  }

  Future<void> verifyQuestion(Question question) async {
    DocumentReference q = _db.collection('questions').document(question.id);
      return await _db.runTransaction((transaction) => transaction.update(q, {'is_verified': true}));
  }

  Future<void> deleteQuestion(Question question) async {
    DocumentReference q = _db.collection('questions').document(question.id);
    return await _db.runTransaction((transaction) => transaction.delete(q));
  }
}