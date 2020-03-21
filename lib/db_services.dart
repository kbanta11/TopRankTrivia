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
    GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
    AuthCredential credential = GoogleAuthProvider.getCredential(idToken: googleSignInAuthentication.idToken, accessToken: googleSignInAuthentication.accessToken);
    AuthResult authResult = await _auth.signInWithCredential(credential);
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

  Stream<List<Ladder>> streamLadders({String filter, String userId}) {
    Query query = _db.collection('ladders').where('end_date', isGreaterThanOrEqualTo: DateTime.now());
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
    return _db.collection('questions').where('is_verified', isEqualTo: null).snapshots().map((snap) => snap.documents.map((doc) => Question.fromFirestore(doc)).toList());
  }
  
  Stream<List<Game>> streamGames({Ladder ladder}) {
    return _db.collection('games').where('ladder_id', isEqualTo: ladder.id).snapshots().map((qs) => qs.documents.map((snap) => Game.fromFirestore(snap)).toList());
  }

  Stream<Game> streamGame(String ladderId, String userId) {
    return _db.collection('games').where('ladder_id', isEqualTo: ladderId).where('user_id', isEqualTo: userId).snapshots().map((snap) => snap.documents.map((doc) => Game.fromFirestore(doc)).first);
  }

  Future<Question> getQuestion() async {
    List<Question> questionList = await _db.collection('questions').where('is_verified', isEqualTo: true).getDocuments().then((QuerySnapshot querySnap) => querySnap.documents.map((doc) => Question.fromFirestore(doc)).toList());
    int randomNum = Random().nextInt(questionList.length);
    return questionList[randomNum];
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

  Future<Game> createGame({Ladder ladder, User user, String type}) async {
    //Create game doc
    DocumentReference docRef = _db.collection('games').document();
    WriteBatch batch = _db.batch();
    batch.setData(docRef, {
      'id': docRef.documentID,
      'ladder_id': ladder.id,
      'user_id': user.userId,
      'user_displayname': user.displayName,
      'total_score': 0,
      'streak': 0,
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

  Future<void> answerQuestion(Answer ans, Game game, Question question) async {
    print('${game.id}');
    WriteBatch batch = _db.batch();
    DocumentReference gameRef = _db.collection('games').document(game.id);
    int currentScore = await gameRef.get().then((snap) => snap.data['total_score']);
    int streak = await gameRef.get().then((snap) => snap.data['streak']);
    int livesLeft = await gameRef.get().then((snap) => snap.data['lives_remaining']);
    int newScore = currentScore;
    bool isAlive = true;
    if(ans != null && ans.isCcorrect){
      if(streak == null)
        streak = 0;
      newScore = currentScore + pow(2, streak);
      streak = streak + 1;
    } else {
      livesLeft = livesLeft - 1;
      isAlive = false;
      streak = 0;
    }
    batch.updateData(gameRef, {
      'total_score': newScore,
      'streak': streak,
      'is_alive': isAlive,
      'lives_remaining': livesLeft,
      'last_question_time': DateTime.now(),
    });

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
    await batch.commit();
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