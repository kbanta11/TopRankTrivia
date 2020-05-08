import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:html_unescape/html_unescape.dart';

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
  String subject;
  String message;
  DateTime ladderEndDate;
  bool isRead;

  Message({
    this.messageId,
    this.ladderId,
    this.subject,
    this.message,
    this.ladderEndDate,
    this.isRead
  });

  factory Message.fromFirestore(DocumentSnapshot snap) {
    print('${snap.data['ladder_end_date'].toDate()}');
    return Message(
      messageId: snap.documentID,
      ladderId: snap.data['ladder_id'].toString(),
      ladderEndDate: snap.data['ladder_end_date'].toDate(),
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

  Question({
    this.id,
    this.category,
    this.difficulty,
    this.type,
    this.question,
    this.answers,
    this.timesAnswered,
    this.answerCounts,
    this.isVerified
  });

  factory Question.fromFirestore(DocumentSnapshot snap) {
    Map data = snap.data;
    Answer correctAnswer = Answer(value: snap.data['correct_answer'], isCcorrect: true);
    List<dynamic> answerValues = snap.data['incorrect_answers'];
    List<Answer> answers = answerValues.map((item) => Answer(value: HtmlUnescape().convert(item), isCcorrect: false)).toList();
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': this.question,
      'correct_answer': this.answers.where((element) => element.isCcorrect).first.value,
      'incorrect_answers': this.answers.where((element) => !element.isCcorrect).map((e) => e.value).toList(),
      'category': this.category,
    };
  }
}

class Answer {
  String value;
  bool isCcorrect;

  Answer({
    this.value,
    this.isCcorrect
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