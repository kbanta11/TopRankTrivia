import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_admob/firebase_admob.dart';
import'package:provider/provider.dart';
import 'package:trivia_game/LadderPage.dart';
import 'package:trivia_game/main.dart';
import 'LoginPage.dart';
import 'models.dart';
import 'db_services.dart';

const String AD_MOB_APP_ID = 'ca-app-pub-5887055143640982~1017841422';
//const String AD_MOB_TEST_DEVICE;
const String AD_MOB_AD_ID = 'ca-app-pub-5887055143640982/1448058598';

class PlayPage extends StatefulWidget {
  Ladder ladder;

  PlayPage({Key key, this.ladder}) : super(key: key);

  @override
  PlayPageState createState() => PlayPageState();
}

class PlayPageState extends State<PlayPage> {
  Ladder ladder;
  bool gettingQuestion = false;

  @override
  void initState() {
    ladder = widget.ladder;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  build(BuildContext context) {
    FirebaseUser currentUser = Provider.of<FirebaseUser>(context);
    return StreamProvider<Game>(
      create: (context) =>  DBService().streamGame(ladder.id, currentUser.uid).handleError((err) => print(err)),
      child: Consumer<Game>(
        builder: (context, game, _) {
          if(game == null)
            return Center(child: CircularProgressIndicator(),);
          return WillPopScope(
            onWillPop: () => Future.value(false),
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/PlayBackground.png'),
                    fit: BoxFit.fill
                  )
              ),
              child: Scaffold(
                appBar: AppBar(
                  leading: TopMenu(),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text('Top Rank Trivia', style: TextStyle(fontSize: 28, color: Colors.white),),
                ),
                backgroundColor: Colors.transparent,
                body: ChangeNotifierProvider<GameProvider>(
                  create: (context) => GameProvider(),
                  child: Consumer<GameProvider>(
                    builder: (context, gp, _) {
                      return Column(
                        children: <Widget>[
                          gp.currentQuestion == null ? Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    alignment: Alignment.center,
                                    child: InkWell(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage('assets/images/StartGameBtn.png'),
                                                fit: BoxFit.fill
                                            )
                                        ),
                                        //alignment: Alignment.center,
                                        child: Padding(
                                          padding: EdgeInsets.all(15),
                                          child: Text('Start Game', style: TextStyle(fontSize: 24, color: Colors.white)),
                                        ),
                                      ),
                                      onTap: () async {
                                        if(!gettingQuestion) {
                                          gettingQuestion = true;
                                          await gp.getQuestion(game);
                                          gettingQuestion = false;
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              )
                          ) : Expanded(
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.fromLTRB(15, 15, 15, 10),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: AssetImage('assets/images/QuestionBackground.png'),
                                              fit: BoxFit.fill
                                          )
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(15,30,15,30),
                                        child: Container(
                                          child: Center(child: Text('${gp.currentQuestion.question}', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Sans', fontSize: 16),)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text('Score: ${game == null ? '' : game.totalScore}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                                          Text('Pts: ${game == null ? '' : pow(2, game.streak)}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),)
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    child: !gp.isAnswered ? Container() : Padding(
                                      padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                                      child: Center(
                                          child: FlatButton(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
                                            child: Text('${gp.chosenAnswer != null && gp.chosenAnswer.isCcorrect ? 'Next Question!' : 'Back to Ladder'}', style: TextStyle(fontSize: 24),),
                                            color: Colors.deepOrangeAccent,
                                            onPressed: () async {
                                              if(gp.chosenAnswer != null && gp.chosenAnswer.isCcorrect) {
                                                if(!gettingQuestion){
                                                  gettingQuestion = true;
                                                  await gp.getQuestion(game);
                                                  gettingQuestion = false;
                                                }
                                              } else {
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => LadderPage(ladder)));
                                              }
                                            },
                                          )
                                      ),
                                    ),
                                  ),
                                  gp.timeLeft == null ? Container() : Padding(
                                    padding: EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: List<int>.generate(10, (i) => i + 1).map((n) => Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 2.5, right: 2.5),
                                          child: Container(
                                            height: 5,
                                            width: 20,
                                            color: n <= gp.timeLeft.inSeconds ? Colors.deepOrangeAccent : Colors.white,
                                          ),
                                        ),
                                      )).toList(),
                                    ),
                                  ),
                                  SingleChildScrollView(
                                    child: Column(
                                      children: gp.currentQuestion.answers.map((Answer answer) {
                                        return Column(
                                          children: <Widget>[
                                            InkWell(
                                              child: Container(
                                                width: MediaQuery.of(context).size.width - 30,
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image: AssetImage(gp.inactiveAnswers != null && gp.inactiveAnswers.contains(answer.value) ? 'assets/images/AnswerBar-Gray.png' : gp.isAnswered != null && !gp.isAnswered ? 'assets/images/AnswerBar.png' : answer.isCcorrect ? 'assets/images/RightAnswer.png' : gp.chosenAnswer != null && gp.chosenAnswer == answer ? 'assets/images/WrongAnswer.png' : 'assets/images/AnswerBar.png'),
                                                        fit: BoxFit.fill
                                                    )
                                                ),
                                                alignment: Alignment.centerLeft,
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(55, 15, 15, 15),
                                                  child: Container(
                                                    width: MediaQuery.of(context).size.width,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: <Widget>[
                                                        Expanded(
                                                          child: Container(
                                                            child: Text('${answer.value}',
                                                                style: TextStyle(
                                                                  fontFamily: 'Sans',
                                                                  fontSize: 16,
                                                                  color: gp.isAnswered != null && gp.isAnswered && (answer.isCcorrect || gp.chosenAnswer == answer) ? Colors.white : Colors.black,
                                                                )
                                                            ),
                                                          ),
                                                        ),
                                                        Text('${gp.showStats ? gp.currentQuestion.answerCounts != null && gp.currentQuestion.answerCounts[answer.value] != null ? gp.currentQuestion.answerCounts[answer.value] : '0' : ''}')
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                //color: gp.inactiveAnswers != null && gp.inactiveAnswers.contains(answer.value) ? Colors.grey : gp.isAnswered != null && !gp.isAnswered ? Colors.white : answer.isCcorrect ? Colors.greenAccent : gp.chosenAnswer != null && gp.chosenAnswer == answer ? Colors.redAccent : Colors.white,
                                              ),
                                              onTap: () {
                                                if(gp.inactiveAnswers != null && gp.inactiveAnswers.contains(answer.value))
                                                  return;
                                                print('Game: $game');
                                                if(!gp.isAnswered)
                                                  gp.answerQuestion(answer, game, gp.currentQuestion);
                                              },
                                            ),
                                            SizedBox(height: 15,)
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  Expanded(child: Container(),),
                                  Container(
                                    height: 90,
                                    width: MediaQuery.of(context).size.width,
                                    child: Stack(
                                      children: <Widget>[
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                              height: 50,
                                              width: MediaQuery.of(context).size.width,
                                              decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      image: AssetImage('assets/images/PlayBottomBar.png')
                                                  )
                                              )
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.topCenter,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              InkWell(
                                                  child: Container(
                                                      height: 80,
                                                      width: 80,
                                                      decoration: BoxDecoration(
                                                          image: DecorationImage(
                                                              image: AssetImage(gp.has5050 ? 'assets/images/5050Btn.png' : 'assets/images/5050Btn-Gray.png')
                                                          )
                                                      )
                                                  ),
                                                  onTap: () {
                                                    if(gp.has5050 && !gp.isAnswered) {
                                                      gp.use5050();
                                                    }
                                                  }
                                              ),
                                              SizedBox(width: 20),
                                              InkWell(
                                                child: Container(
                                                    height: 80,
                                                    width: 80,
                                                    decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                            image: AssetImage(gp.hasStats ? 'assets/images/CommunityBtn.png' : 'assets/images/CommunityBtn-Gray.png')
                                                        )
                                                    )
                                                ),
                                                onTap: () {
                                                  if(gp.hasStats && !gp.isAnswered)
                                                    gp.useStats();

                                                },
                                              ),
                                              SizedBox(width: 20),
                                              InkWell(
                                                child: Container(
                                                    height: 80,
                                                    width: 80,
                                                    decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                            image: AssetImage(gp.hasReroll ? 'assets/images/DiceBtn.png' : 'assets/images/DiceBtn-Gray.png')
                                                        )
                                                    )
                                                ),
                                                onTap: () {
                                                  if(gp.hasReroll && !gp.isAnswered)
                                                    gp.useReroll(game);
                                                },
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              )
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            )
          );
        },
      ),
    );
  }
}

class GameProvider extends ChangeNotifier {
  Question currentQuestion;
  Answer chosenAnswer;
  Timer questionTimer;
  final Duration startTime = new Duration(seconds: 10);
  Duration timeLeft;
  bool isAnswered = false;
  bool hasStarted;
  List<String> inactiveAnswers;
  bool has5050 = true;
  bool hasStats = true;
  bool showStats = false;
  bool hasReroll = true;

  Future<void> getQuestion(Game game) async {
    showStats = false;
    inactiveAnswers = null;
    hasStarted = true;
    currentQuestion = await DBService().getQuestion();
    chosenAnswer = null;
    timeLeft = startTime;
    isAnswered = false;
    if(questionTimer != null)
      questionTimer.cancel();
    questionTimer = new Timer.periodic(Duration(seconds: 1), (timer) {
      timeLeft = Duration(seconds: timeLeft.inSeconds - 1);
      print('Time left: ${timeLeft.inSeconds}');
      if(timeLeft.inSeconds <= 0) {
        questionTimeout(game, currentQuestion);
        timer.cancel();
      }
      notifyListeners();
    });
    notifyListeners();
    return;
  }

  void answerQuestion (Answer answer, Game game, Question question) {
    print('${answer != null && answer.isCcorrect ? 'Correct!' : 'Incorrect'}: ${answer != null ? answer.value : ''}');
    chosenAnswer = answer;
    isAnswered = true;
    if(questionTimer != null)
      questionTimer.cancel();
    questionTimer = null;
    timeLeft = null;
    DBService().answerQuestion(answer, game, question);
    notifyListeners();
  }

  void use5050() {
    has5050 = false;
    List<Answer> incorrectAnswers = currentQuestion.answers.where((element) => !element.isCcorrect).toList();
    incorrectAnswers.shuffle();
    inactiveAnswers = incorrectAnswers.getRange(0, 2).map((e) => e.value).toList();
    print(inactiveAnswers);
    notifyListeners();
  }

  void useReroll(Game game) {
    hasReroll = false;
    getQuestion(game);
    notifyListeners();
  }

  void useStats(){
    hasStats = false;
    showStats = true;
    notifyListeners();
  }

  void questionTimeout(Game game, Question question) {
    print('Question Timeout');
    answerQuestion(null, game, question);
  }
}