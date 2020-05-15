import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:html_unescape/html_unescape.dart';
import 'db_services.dart';

class User {
  String userId;
  String displayName;
  String email;
  String photoUrl;
  int coins;
  int bars;
  int laddersEntered;
  int laddersPlaced;
  int laddersWon;
  bool isAdmin;
  Map recentQuestions;
  int numHeadToHead;

  User({
    this.userId,
    this.displayName,
    this.email,
    this.photoUrl,
    this.coins,
    this.bars,
    this.laddersEntered,
    this.laddersPlaced,
    this.laddersWon,
    this.isAdmin,
    this.recentQuestions,
    this.numHeadToHead,
  });

  factory User.fromFirestore(DocumentSnapshot snap) {
    if(snap.exists){
      print('no user doc');
    }
    Map data = snap.data;
    return User(
      userId: data['userId'],
      displayName: data['displayName'],
      email: data['email'],
      photoUrl: data['photoUrl'],
      coins: data['coins'],
      bars: data['bars'],
      laddersEntered: data['laddersEntered'],
      laddersPlaced: data['laddersPlaced'],
      laddersWon: data['laddersWon'],
      numHeadToHead: data['num_head_to_head'] ?? 0,
      isAdmin: data['is_admin'] ?? false,
      recentQuestions: data['recent_questions'] ?? null,
    );
  }

  String getDisplayName({String nm}) {
    String _name = nm;
    if(_name == null)
      nm = this.displayName;

    List nameParts = nm.split(' ');
    String name = nameParts[0];
    if(nameParts.length > 1) {
      nameParts.sublist(1).forEach((element) {
        name = name + ' ${element.toString().substring(0, 1)}.';
      });
    }
    return name;
  }
}

class Message {
  String messageId;
  String ladderId;
  String gameId;
  String subject;
  String message;
  DateTime ladderEndDate;
  DateTime dateSent;
  bool isRead;

  Message({
    this.messageId,
    this.ladderId,
    this.gameId,
    this.subject,
    this.message,
    this.ladderEndDate,
    this.dateSent,
    this.isRead
  });

  factory Message.fromFirestore(DocumentSnapshot snap) {
    return Message(
      messageId: snap.documentID,
      ladderId: snap.data['ladder_id'],
      gameId: snap.data['game_id'],
      ladderEndDate: snap.data['ladder_end_date'] is Timestamp ? snap.data['ladder_end_date'].toDate() : null,
      dateSent: snap.data['datesent'] is Timestamp ? snap.data['datesent'].toDate() : DateTime(1900),
      subject: snap.data['message_subject'].toString(),
      message: snap.data['message'].toString(),
      isRead: snap.data['is_read'],
    );
  }
}

class Ladder {
  String id;
  String title;
  DateTime startDate;
  DateTime endDate;
  Duration respawnTime;
  int numLives;
  int entryFee;
  List<Game> games;
  int numGames;
  String type;
  String prize;
  bool hasPrize;

  Ladder({
    this.id,
    this.title,
    this.startDate,
    this.endDate,
    this.entryFee,
    this.numLives,
    this.respawnTime,
    this.games,
    this.numGames,
    this.type,
    this.hasPrize,
    this.prize,
  });

  factory Ladder.fromFirestore(DocumentSnapshot snap) {
    Map data = snap.data;
    Timestamp endTimestamp = data['end_date'];
    Timestamp startTimestamp = data['start_date'];
    return Ladder(
      id: snap.documentID,
      title: data['title'],
      startDate: startTimestamp.toDate(),
      endDate: endTimestamp.toDate(),
      respawnTime: Duration(minutes: data['respawn_minutes']),
      numLives: data['lives'],
      entryFee: data['entry_fee'],
      type: data['type'] ?? 'coins',
      numGames: data['num_games'] ?? 0,
    );
  }
}

class Game {
  String id;
  String userId;
  String ladderId;
  String userDisplayname;
  int totalScore;
  int livesRemaining;
  int streak;
  int highStreak;
  DateTime entryDate;
  DateTime lastQuestionDate;
  bool isAlive;

  Game({
    this.id,
    this.userId,
    this.ladderId,
    this.userDisplayname,
    this.totalScore,
    this.livesRemaining,
    this.entryDate,
    this.lastQuestionDate,
    this.isAlive,
    this.streak,
    this.highStreak,
  });

  factory Game.fromFirestore(DocumentSnapshot snap) {
    Map data = snap.data;
    Timestamp entryTime = data['entry_time'];
    Timestamp lastQuestionTime =data['last_question_time'];
    return Game(
      id: snap.documentID,
      userId: data['user_id'],
      ladderId: data['ladder_id'],
      userDisplayname: data['user_displayname'],
      totalScore: data['total_score'],
      livesRemaining: data['lives_remaining'],
      entryDate: entryTime == null ? null : entryTime.toDate(),
      lastQuestionDate: lastQuestionTime == null ? null : lastQuestionTime.toDate(),
      isAlive: data['is_alive'],
      streak: data['streak'],
      highStreak: data['high_streak'] ?? 0,
    );
  }

  Stream<Duration> timeSinceLastQuestion() {
    return Stream.periodic(Duration(seconds: 1), (i){
      if(lastQuestionDate == null) {
        return Duration(minutes: 10000);
      }
      return DateTime.now().difference(lastQuestionDate);
    });
  }
}

class HeadToHeadGame {
  String id;
  int entryFee;
  DateTime dateStarted;
  DateTime dateFinished;
  List<String> players;
  String winner;
  bool gameFinished;
  List<Question> questions;
  //Player 1
  String player1;
  String player1Name;
  int player1Bet;
  int player1Score;
  bool player1Finished;
  int player1Streak;
  bool player1Used5050;
  bool player1UsedStats;
  bool player1UsedReroll;
  //Player 2
  String player2;
  String player2Name;
  int player2Bet;
  int player2Score;
  bool player2Finished;
  int player2Streak;
  bool player2Used5050;
  bool player2UsedStats;
  bool player2UsedReroll;

  HeadToHeadGame({
    this.id,
    this.entryFee,
    this.dateStarted,
    this.dateFinished,
    this.winner,
    this.players,
    this.gameFinished,
    this.questions,
    //Player 1
    this.player1,
    this.player1Name,
    this.player1Bet,
    this.player1Score,
    this.player1Finished,
    this.player1Streak,
    this.player1Used5050,
    this.player1UsedStats,
    this.player1UsedReroll,
    //Player 2
    this.player2,
    this.player2Name,
    this.player2Bet,
    this.player2Score,
    this.player2Finished,
    this.player2Streak,
    this.player2Used5050,
    this.player2UsedStats,
    this.player2UsedReroll,
  });

  factory HeadToHeadGame.fromFirestore(DocumentSnapshot doc) {
    print('Players: ${doc.data['players']}');
    List<String> players = List<String>();
    if(doc.data['players'] != null)
      doc.data['players'].forEach((item) {
        print('item ${item.runtimeType}');
        players.add(item);
      });
    print('Players: $players');
    return HeadToHeadGame(
      id: doc.documentID,
      entryFee: doc.data['entry_fee'],
      dateStarted: doc.data['datestarted'].toDate(),
      dateFinished: doc.data['date_finished'] == null ? null : doc.data['date_finished'].toDate(),
      players: players,
      winner: doc.data['winner'],
      gameFinished: doc.data['game_finished'] ?? false,
      //Player 1
      player1: doc.data['player1'],
      player1Name: doc.data['player1_name'],
      player1Score: doc.data['player1_score'],
      player1Bet: doc.data['player1_bet'],
      player1Streak: doc.data['player1_streak'],
      player1Finished: doc.data['player1_finished'] ?? false,
      player1Used5050: doc.data['player1_used_5050'] ?? false,
      player1UsedStats: doc.data['player1_used_stats'] ?? false,
      player1UsedReroll: doc.data['player1_used_reroll'] ?? false,
      //Player 2
      player2: doc.data['player2'],
      player2Name: doc.data['player2_name'],
      player2Score: doc.data['player2_score'],
      player2Bet: doc.data['player2_bet'],
      player2Streak: doc.data['player2_streak'],
      player2Finished: doc.data['player2_finished'] ?? false,
      player2Used5050: doc.data['player2_used_5050'] ?? false,
      player2UsedStats: doc.data['player2_used_stats'] ?? false,
      player2UsedReroll: doc.data['player2_used_reroll'] ?? false,
    );
  }

  Future<void> getQuestions() async {
    this.questions = await DBService().getGameQuestions(this.id);
  }
}

class Question {
  String id;
  String category;
  String difficulty;
  String type;
  String question;
  List<Answer> answers;
  int timesAnswered;
  Map answerCounts;
  bool isVerified;
  int order;
  bool bonus;
  List<String> playersAnswered;
  bool player1Correct;
  bool player2Correct;

  Question({
    this.id,
    this.category,
    this.difficulty,
    this.type,
    this.question,
    this.answers,
    this.timesAnswered,
    this.answerCounts,
    this.isVerified,
    this.order,
    this.bonus,
    this.playersAnswered,
    this.player1Correct,
    this.player2Correct,
  });

  factory Question.fromFirestore(DocumentSnapshot snap) {
    Map data = snap.data;
    Answer correctAnswer = Answer(value: snap.data['correct_answer'], isCorrect: true);
    List<dynamic> answerValues = snap.data['incorrect_answers'];
    List<Answer> answers = answerValues.map((item) => Answer(value: HtmlUnescape().convert(item), isCorrect: false)).toList();
    answers.add(correctAnswer);
    answers.shuffle();
    return Question(
      id: snap.documentID,
      category: data['category'] != null ? data['category'].toString() : '',
      difficulty: data['difficulty'],
      type: data['type'],
      question: HtmlUnescape().convert(data['question']),
      answers: answers,
      timesAnswered: data['times_answered'] ?? 0,
      answerCounts: data['answer_counts'],
      isVerified: data['is_verified'] ?? false,
      order: data['order'] ?? 0,
      bonus: data['bonus'] ?? false,
      playersAnswered: data['players_answered'] == null ? null : data['players_answered'].cast<String>(),
      player1Correct: data['player1_correct'],
      player2Correct: data['player2_correct'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': this.question,
      'correct_answer': this.answers.where((element) => element.isCorrect).first.value,
      'incorrect_answers': this.answers.where((element) => !element.isCorrect).map((e) => e.value).toList(),
      'category': this.category,
    };
  }
}

class Answer {
  String value;
  bool isCorrect;

  Answer({
    this.value,
    this.isCorrect
  });
}

class Helper {
  String dateToString(DateTime date) {
    DateTime localDate = date.toLocal();
    DateFormat format = DateFormat('EEEE, MMMM d, y h:mm aa');
    return '${format.format(localDate)}';
  }

  String dateTimeToStringShort(DateTime date) {
    DateTime localDate = date.toLocal();
    DateFormat format = DateFormat('MM/dd/yyyy h:mm aa');
    return '${format.format(localDate)}';
  }

  String formatNumber(int value) {
    return '${value >= 1000000 ? '${NumberFormat('#.#').format(value/1000000)}M' : value >= 100000 ? '${NumberFormat('#.#').format(value)}K' : NumberFormat('#,###').format(value)}';
  }
}