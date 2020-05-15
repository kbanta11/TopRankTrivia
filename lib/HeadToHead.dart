import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models.dart';
import 'db_services.dart';
import 'main.dart';

class HeadToHeadPage extends StatelessWidget {
  @override
  build(BuildContext context) {
    FirebaseUser currentUser = Provider.of<FirebaseUser>(context);
    return StreamProvider(
      create: (context) => DBService().streamUserDoc(currentUser),
      child: Consumer<User>(
        builder: (context, user, _) {
          return user == null ? Center(child: CircularProgressIndicator()) : WillPopScope(
            onWillPop: () => Future.value(false),
            child: Scaffold(
              body: Column(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/topPanelbg.png'),
                        fit: BoxFit.fill
                      )
                    ),
                    child: Column(
                      children: <Widget>[
                        AppBar(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            leading: TopMenu(),
                            title: Text('Head to Head', style: TextStyle(fontSize: 28, color: Colors.white),)
                        ),
                        Padding(
                            padding: EdgeInsets.fromLTRB(10, 5, 10, 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  width: 160,
                                  height: 55,
                                  child: Stack(
                                    children: <Widget>[
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          width: 115,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                                            color: Colors.black38,
                                          ),
                                          alignment: Alignment.centerRight,
                                          padding: EdgeInsets.only(right: 15),
                                          child: Text(user != null ? Helper().formatNumber(user.coins) : '', style: TextStyle(fontSize: 24, color: Colors.white), textAlign: TextAlign.right,),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                            height: 55,
                                            width: 55,
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: AssetImage('assets/images/CoinIcon.png'),
                                                    fit: BoxFit.fill
                                                )
                                            )
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 120,
                                  height: 55,
                                  child: Stack(
                                    children: <Widget>[
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          width: 75,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                                            color: Colors.black38,
                                          ),
                                          alignment: Alignment.centerRight,
                                          padding: EdgeInsets.only(right: 15),
                                          child: Text(user != null ? user.bars.toString() : '', style: TextStyle(fontSize: 24, color: Colors.white), textAlign: TextAlign.right),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                            height: 55,
                                            width: 55,
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: AssetImage('assets/images/GoldBarIcon.png'),
                                                    fit: BoxFit.fill
                                                )
                                            )
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            )
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                      child: StreamProvider<List<HeadToHeadGame>>.value(
                        value: DBService().streamHeadToHeadGames(user),
                        child: Consumer<List<HeadToHeadGame>>(
                          builder: (context, gameList, _) {
                            return ListView(
                                scrollDirection: Axis.vertical,
                                children: gameList == null || gameList.length == 0 ? [Center(child: Text('You haven\'t played your first head-to-head game yet!'))]
                                    : gameList.map((game) => Padding(
                                  padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
                                  child: InkWell(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: AssetImage('assets/images/LadderTilebg.png'),
                                              fit: BoxFit.fill
                                          )
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
                                        child: Column(
                                            children: <Widget>[
                                              Text('Entry Fee: ${game.entryFee}', style: TextStyle(fontSize: 18)),
                                              Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                        child: Column(
                                                          children: <Widget>[
                                                            Text('${game.player1Name != null ? game.player1Name : 'Waiting for Opponent'}', style: TextStyle(fontSize: 22), textAlign: TextAlign.center,),
                                                            Text('Score: ${game.player1 != user.userId && (game.player2Finished != null && !game.player2Finished) ? '--' : game.player1Score ?? '0'}', style: TextStyle(fontSize: 18)),
                                                            game.gameFinished ? game.player1Score > game.player2Score ? Icon(Icons.check_circle, color: Colors.greenAccent) : FaIcon(FontAwesomeIcons.solidTimesCircle, color: Colors.redAccent)
                                                                : game.player1 != null  && !game.player1Finished ? Text('In Progress...') : Container()
                                                          ],
                                                        )
                                                    ),
                                                    Container(
                                                        width: 25,
                                                        child: Text('vs.')
                                                    ),
                                                    Expanded(
                                                        child: Column(
                                                          children: <Widget>[
                                                            Text('${game.player2Name != null ? game.player2Name : 'Waiting for Opponent'}', style: TextStyle(fontSize: 22), textAlign: TextAlign.center,),
                                                            Text('Score: ${game.player2 != user.userId && (game.player1Finished != null && !game.player1Finished) ? '--' : game.player2Score ?? '0'}', style: TextStyle(fontSize: 18)),
                                                            game.gameFinished ? game.player2Score > game.player1Score ? Icon(Icons.check_circle, color: Colors.greenAccent) : FaIcon(FontAwesomeIcons.solidTimesCircle, color: Colors.redAccent)
                                                                : game.player2 != null && !game.player2Finished ? Text('In Progress...') : Container()
                                                          ],
                                                        )
                                                    )
                                                  ]
                                              )
                                            ]
                                        ),
                                      ),
                                    ),
                                    onTap: () async {
                                      if((game.player1 == user.userId && game.player1Finished) || (game.player2 == user.userId && game.player2Finished)) {
                                        //Show end game overview dialog
                                        await showDialog(
                                          context: context,
                                          builder: (context) {
                                            return HeadToHeadOverview(game: game, user: user);
                                          }
                                        );
                                      } else {
                                        //Send user to game to finish
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => HeadToHeadPlay(game: game)));
                                      }
                                    }
                                  ),
                                )).toList());
                          },
                        ),
                      ),
                    )
                  ),
                  ChangeNotifierProvider<StartGameProvider>(
                    create: (context) => StartGameProvider(),
                    child: Consumer<StartGameProvider>(
                      builder: (context, startGameProvider, _) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [100, 250, 500, 1000, 5000, -1].map((val) {
                            if(val > 0) {
                              //Button to select value
                              return InkWell(
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      color: startGameProvider.selectedAmount == val ? Colors.cyan : Colors.transparent,
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                      border: Border.all(color: Colors.cyan)
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        height: 20,
                                        width: 20,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage('assets/images/Coins.png')
                                            )
                                        ),
                                      ),
                                      Text('$val', style: TextStyle(fontSize: 16, color: startGameProvider.selectedAmount == val ? Colors.white : Colors.black))
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  startGameProvider.selectNewAmount(val);
                                },
                              );
                            } else {
                              //Start game button
                              return InkWell(
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage('assets/images/StartGameBtn.png'),
                                        fit: BoxFit.fill
                                    ),
                                  ),
                                  child: Center(
                                    child: Text('Start a Game', style: TextStyle(fontSize: 18, color: Colors.white),),
                                  ),
                                ),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                        title: user.coins < startGameProvider.selectedAmount ? Text('Sorry! Not Enough Coins!') : Text('Are you sure?'),
                                        content: user.coins < startGameProvider.selectedAmount ? Text('You do not have enough coins to bet this much. Try a smaller wager!', style: TextStyle(fontSize: 18)) : Text('You are about to bet ${startGameProvider.selectedAmount} coins in this head-to-head game. Are you ready?', style: TextStyle(fontSize: 18)),
                                        actions: <Widget>[
                                          FlatButton(
                                            child: Text('Cancel', style: TextStyle(fontSize: 18, color: Colors.black),),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          user.coins < startGameProvider.selectedAmount ? Container() : FlatButton(
                                            color: Colors.cyan,
                                              child: Text('Start Game', style: TextStyle(fontSize: 18, color: Colors.white)),
                                              onPressed: () async {
                                                //Start game logic
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return Center(
                                                      child: CircularProgressIndicator(),
                                                    );
                                                  }
                                                );
                                                DBService().getHeadToHeadGame(user, startGameProvider.selectedAmount).then((HeadToHeadGame game) {
                                                  Navigator.of(context).pop();
                                                  print('Game Started: ${game.player1} v. ${game.player2 ?? '____'}, ${game.questions.length} questions/Game ID: ${game.id}');
                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => HeadToHeadPlay(game: game)));
                                                });
                                              }
                                          )
                                        ],
                                      );
                                    }
                                  );
                                },
                              );
                            }
                          }).toList(),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 10.0),
                  BottomNavBar(selected: 'head',),
                ],
              )
            ),
          );
        }
      )
    );
  }
}

class StartGameProvider extends ChangeNotifier {
  int selectedAmount = 100;

  void selectNewAmount(int value) {
    selectedAmount = value;
    notifyListeners();
  }
}

//----------------------HeadToHeadPlay--------------------------------//
class HeadToHeadPlay extends StatefulWidget {
  HeadToHeadGame game;

  HeadToHeadPlay({Key key, this.game}) : super(key: key);

  @override
  HeadToHeadPlayState createState() => HeadToHeadPlayState();
}

class HeadToHeadPlayState extends State<HeadToHeadPlay> {
  HeadToHeadGame game;
  bool gettingQuestion = false;

  @override
  void initState() {
    game = widget.game;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  build(BuildContext context) {
    FirebaseUser currentUser = Provider.of<FirebaseUser>(context);
    User user = Provider.of<User>(context);
    print('Game Id: ${game.id}');
    return StreamProvider<HeadToHeadGame>(
      create: (context) =>  DBService().streamHeadToHeadGame(game.id),
      child: Consumer<HeadToHeadGame>(
        builder: (context, game, _) {
          if(game == null) {
            print('Game: $game');
            return Center(child: CircularProgressIndicator(),);
          }
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
                    title: Text('Top Trivia', style: TextStyle(fontSize: 28, color: Colors.white),),
                  ),
                  backgroundColor: Colors.transparent,
                  body: ChangeNotifierProvider<HeadToHeadGameProvider>(
                    create: (context) => HeadToHeadGameProvider(),
                    child: Consumer<HeadToHeadGameProvider>(
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
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return Center(
                                                    child: CircularProgressIndicator(),
                                                  );
                                                }
                                            );
                                            await gp.getNextQuestion(game, user).then((_) {
                                              Navigator.of(context).pop();
                                            });
                                            gettingQuestion = false;
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                )
                            ) : gp.questionBonus && ((game.player1 == user.userId && game.player1Bet == 0) || (game.player2 == user.userId && game.player2Bet == 0)) ? Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text('Bonus Question!', style: TextStyle(fontSize: 36, color: Colors.white)),
                                      SizedBox(height: 20),
                                      Container(
                                        padding: EdgeInsets.fromLTRB(15, 5, 15, 15),
                                        child: Text('Here\'s your chance to go big or go home. You can bet up to all of your points (you must bet at least 1 point). Get it right and win double your bet. Get it wrong and you\'ll lose the points that you bet. Gonna risk it for the biscuit?', style: TextStyle(fontSize: 22, color: Colors.white), textAlign: TextAlign.center,),
                                      ),
                                      Text('You have ${game.player1 == user.userId ? game.player1Score : game.player2Score} points to bet', style: TextStyle(fontSize: 22, color: Colors.white)),
                                      SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(Radius.circular(15))
                                        ),
                                        width: 150,
                                        padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                                        child: TextField(
                                          inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                                          decoration: InputDecoration(hintText: 'Bet Here!', fillColor: Colors.white),
                                          keyboardType: TextInputType.number,
                                          style: TextStyle(fontSize: 22),
                                          textAlign: TextAlign.center,
                                          onChanged: (value) {
                                            print('Betting: ${int.parse(value)} points');
                                            gp.setBetAmount(int.parse(value));
                                          },
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      FlatButton(
                                          child: Container(
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: AssetImage('assets/images/StartGameBtn.png'),
                                                    fit: BoxFit.fill
                                                )
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                                              child: Text('BET', style: TextStyle(fontSize: 30, color: Colors.white)),
                                            ),
                                          ),
                                          onPressed: () async {
                                            int playerScore = game.player1 == user.userId ? game.player1Score : game.player2Score;
                                            bool betError = false;
                                            String reason;
                                            String message;
                                            if(gp.betAmount == null || !(gp.betAmount > 0)) {
                                              betError = true;
                                              reason = 'Missing Bet!';
                                              message = 'You must bet at least 1 point. Where\'s the fun without a little risk?';
                                            } else if(gp.betAmount > playerScore) {
                                              betError = true;
                                              reason = 'Not Enough Points';
                                              message = 'You cannot bet more points than you have this game! Please enter an amount up to your total points for this game.';
                                            }
                                            if(betError) {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                                      title: Text(reason),
                                                      content: Text(message, style: TextStyle(fontSize: 18)),
                                                      actions: <Widget>[
                                                        FlatButton(
                                                          child: Text('OK'),
                                                          onPressed: () {
                                                            Navigator.of(context).pop();
                                                          },
                                                        )
                                                      ],
                                                    );
                                                  }
                                              );
                                            } else {
                                              FocusScope.of(context).unfocus();
                                              await gp.makeBet(user, game);
                                            }
                                          }
                                      )
                                    ]
                                ),
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
                                            Text('Score: ${game == null ? '' : game.player1 == user.userId ? game.player1Score : game.player2Score}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                                            Text('Question: ${game == null ? '' : gp.questionNumber == null ? '1' : gp.questionBonus ? 'Bonus' : gp.questionNumber}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),),
                                            Text('${gp.currentQuestion.bonus ? 'Bet' : 'Streak'}: ${game == null ? ''
                                                : game.player1 == user.userId ? gp.currentQuestion.bonus ? game.player1Bet : game.player1Streak
                                                : gp.currentQuestion.bonus ? game.player2Bet : game.player2Streak}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),)
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: !gp.isAnswered ? Container() : Padding(
                                        padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                                        child: Center(
                                          child: Container(
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: AssetImage('assets/images/StartGameBtn.png'),
                                                    fit: BoxFit.fill
                                                )
                                            ),
                                            child: FlatButton(
                                              //shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
                                              child: Text((game.player1 == user.userId && game.player1Finished) || (game.player2 == user.userId  && game.player2Finished) ? 'End Game' : 'Next Question!', style: TextStyle(fontSize: 24, color: Colors.white),),
                                              color: Colors.transparent,
                                              onPressed: () async {
                                                if((game.player1 == user.userId && game.player1Finished) || (game.player2 == user.userId  && game.player2Finished)) {
                                                  //Handle end game - show overview of your stats and opponents stats if opponent has played as well as winner/end game
                                                  await showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return HeadToHeadOverview(game: game, user: user);
                                                    }
                                                  ).then((_) {
                                                    Navigator.push(context, MaterialPageRoute(builder: (context) => HeadToHeadPage()));
                                                  });
                                                } else {
                                                  //get next question
                                                  if(!gettingQuestion){
                                                    gettingQuestion = true;
                                                    showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return Center(
                                                              child: CircularProgressIndicator()
                                                          );
                                                        }
                                                    );
                                                    await gp.getNextQuestion(game, user).then((_) {
                                                      Navigator.of(context).pop();
                                                    });
                                                    gettingQuestion = false;
                                                  }
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    gp.timeLeft == null ? Container(height: 10) : Padding(
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
                                    Expanded(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: Column(
                                          children: gp.currentQuestion.answers.map((Answer answer) {
                                            return Column(
                                              children: <Widget>[
                                                InkWell(
                                                  child: Container(
                                                    width: MediaQuery.of(context).size.width - 30,
                                                    decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                            image: AssetImage(gp.inactiveAnswers != null && gp.inactiveAnswers.contains(answer.value) ? 'assets/images/AnswerBar-Gray.png' : gp.isAnswered != null && !gp.isAnswered ? 'assets/images/AnswerBar.png' : answer.isCorrect ? 'assets/images/RightAnswer.png' : gp.chosenAnswer != null && gp.chosenAnswer == answer ? 'assets/images/WrongAnswer.png' : 'assets/images/AnswerBar.png'),
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
                                                                      color: gp.isAnswered != null && gp.isAnswered && (answer.isCorrect || gp.chosenAnswer == answer) ? Colors.white : Colors.black,
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
                                                      gp.answerQuestion(answer, game, gp.currentQuestion, user);
                                                  },
                                                ),
                                                SizedBox(height: 15,)
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
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
                                                        gp.use5050(game, user.userId == game.player1 ? 1 : 2);
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
                                                      gp.useStats(game, user.userId == game.player1 ? 1 : 2);

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
                                                    //if(gp.hasReroll && !gp.isAnswered)
                                                      //gp.useReroll(game, user);
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

class HeadToHeadGameProvider extends ChangeNotifier {
  Question currentQuestion;
  int questionNumber;
  bool questionBonus = false;
  bool showEndGame = false;
  Answer chosenAnswer;
  Timer questionTimer;
  int betAmount;
  final Duration startTime = new Duration(seconds: 10);
  Duration timeLeft;
  bool isAnswered = false;
  bool hasStarted;
  List<String> inactiveAnswers;
  bool has5050 = true;
  bool hasStats = true;
  bool showStats = false;
  bool hasReroll = false;

  void startTimer(HeadToHeadGame game, User user) {
    timeLeft = startTime;
    if(questionTimer != null)
      questionTimer.cancel();
    questionTimer = new Timer.periodic(Duration(seconds: 1), (timer) {
      timeLeft = Duration(seconds: timeLeft.inSeconds - 1);
      //print('Time left: ${timeLeft.inSeconds}');
      if(timeLeft.inSeconds <= 0) {
        //----TO DO----Handle Question Timeout
        questionTimeout(game, currentQuestion, user);
        timer.cancel();
      }
      notifyListeners();
    });
  }

  Future<void> getNextQuestion(HeadToHeadGame game, User user) async {
    showStats = false;
    inactiveAnswers = null;
    hasStarted = true;
    await game.getQuestions();
    game.questions.sort((a, b) => a.order - b.order);
    List<Question> unansweredQuestions = game.questions.where((q) {
      print('Players answered: ${q.playersAnswered}/');
      return q.playersAnswered == null ? true : !q.playersAnswered.contains(user.userId);
    }).toList();
    currentQuestion = unansweredQuestions.first;
    questionNumber = currentQuestion.order + 1;
    if(currentQuestion.bonus)
      questionBonus = currentQuestion.bonus;
    chosenAnswer = null;
    isAnswered = false;
    if(!currentQuestion.bonus)
      startTimer(game, user);
    notifyListeners();
    return;
  }

  void answerQuestion (Answer answer, HeadToHeadGame game, Question question, User user) {
    print('${answer != null && answer.isCorrect ? 'Correct!' : 'Incorrect'}: ${answer != null ? answer.value : ''}');
    chosenAnswer = answer;
    isAnswered = true;
    if(questionTimer != null)
      questionTimer.cancel();
    questionTimer = null;
    timeLeft = null;
    DBService().answerQuestionHeadToHead(answer, game, question, user);
    notifyListeners();
  }

  void use5050(HeadToHeadGame game, int playerNumber) {
    has5050 = false;
    List<Answer> incorrectAnswers = currentQuestion.answers.where((element) => !element.isCorrect).toList();
    incorrectAnswers.shuffle();
    inactiveAnswers = incorrectAnswers.getRange(0, 2).map((e) => e.value).toList();
    print(inactiveAnswers);
    notifyListeners();
  }

  //Remove reroll in head to head
  /*
  void useReroll(Game game, User user) {
    hasReroll = false;
    getQuestion(game, user);
    notifyListeners();
  }
   */

  void useStats(HeadToHeadGame game, int playerNumber){
    hasStats = false;
    showStats = true;
    notifyListeners();
  }

  void questionTimeout(HeadToHeadGame game, Question question, User user) {
    print('Question Timeout');
    answerQuestion(null, game, question, user);
  }

  void setBetAmount(int value) {
    betAmount = value;
    notifyListeners();
  }

  Future<void> makeBet(User user, HeadToHeadGame game) async {
    await DBService().makeBonusBetHeadToHead(user, game, betAmount);
    startTimer(game, user);
  }
}

//-----------------------------------------------------Game Overview Dialog---------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------------------
class HeadToHeadOverview extends StatelessWidget {
  HeadToHeadGame game;
  User user;

  HeadToHeadOverview({this.game, this.user});

  @override
  build(BuildContext context) {
    return ChangeNotifierProvider<HeadToHeadOverviewProvider>(
      create: (context) => HeadToHeadOverviewProvider(),
      child: Consumer<HeadToHeadOverviewProvider>(
        builder: (context, op, _) {
          if(!op.questionsRetrieved)
            op.getQuestions(game);
          List<Widget> questionRows;
          if(op.questionList != null) {
            op.questionList.sort((a, b) => a.order - b.order);
            questionRows = op.questionList.map((question) {
              return Container(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                child: Row(
                    children: <Widget>[
                      Expanded(
                          child: Center(
                              child: question.player1Correct == null ? Icon(Icons.check_circle_outline, size: 30) : question.player1Correct ? Icon(Icons.check_circle, size: 30, color: Colors.greenAccent) : FaIcon(FontAwesomeIcons.solidTimesCircle, size: 30, color: Colors.redAccent)
                          )
                      ),
                      Container(
                          width: 50,
                          child: Center(child: Text(question.bonus ? 'Bonus' : '${question.order + 1}', style: TextStyle(fontSize: 18)))
                      ),
                      Expanded(
                          child: Center(
                              child: question.player2Correct == null ? Icon(Icons.check_circle_outline, size: 30) : question.player2Correct ? Icon(Icons.check_circle, size: 30, color: Colors.greenAccent) : FaIcon(FontAwesomeIcons.solidTimesCircle, size: 30, color: Colors.redAccent)
                          )
                      )
                    ]
                ),
              );
            }).toList();
          }
          return game == null ? AlertDialog(content: CircularProgressIndicator(),) : AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
            title: Center(child: Text('Game Overview', style: TextStyle(fontSize: 30))),
            content: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                          child: Text('${game.player1Name != null ? game.player1Name : 'No Opponent Yet'}', style: TextStyle(fontSize: 20), textAlign: TextAlign.center,)
                      ),
                      Container(
                          width: 25
                      ),
                      Expanded(
                          child: Text('${game.player2Name != null ? game.player2Name : 'No Opponent Yet'}', style: TextStyle(fontSize: 20), textAlign: TextAlign.center)
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(
                          child: Center(child: Text('${game.player1Score == null ? '0' : game.player1Score}', style: TextStyle(fontSize: 26)))
                      ),
                      Container(
                          width: 50,
                          child: Text('Score', style: TextStyle(fontSize: 18))
                      ),
                      Expanded(
                          child: Center(child: Text('${game.player2Score == null ? '0' : game.player2Score}', style: TextStyle(fontSize: 26)))
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Expanded(
                          child: Center(child: Text('${game.player1Bet == null ? '0' : game.player1Bet}', style: TextStyle(fontSize: 22)))
                      ),
                      Container(
                          width: 50,
                          child: Text('Bonus Bet', style: TextStyle(fontSize: 18), textAlign: TextAlign.center,)
                      ),
                      Expanded(
                          child: Center(child: Text('${game.player2Bet == null ? '0' : game.player2Bet}', style: TextStyle(fontSize: 22)))
                      ),
                    ],
                  ),
                  Divider(height: 20, color: Colors.black,),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: questionRows ?? [Container()],
                      ),
                    )
                  ),
                  SizedBox(height: 10),
                  Text(game.gameFinished && game.winner == user.userId ? 'Congratulations! You won ${game.entryFee * 2} coins!': game.gameFinished && game.winner != user.userId ? 'You lost this one. Better luck next time!' : 'This game is not yet finished. We\'re still waiting for an opponent willing to take you on!', style: TextStyle(fontSize: 18), textAlign: TextAlign.center,)
                ]
            ),
            actions: <Widget>[
              FlatButton(
                  child: Text('OK', style: TextStyle(fontSize: 20, color: Colors.white)),
                  color: Colors.cyan,
                  onPressed: () {
                    Navigator.of(context).pop();
                  }
              )
            ],
          );
        },
      )
    );
  }
}

class HeadToHeadOverviewProvider extends ChangeNotifier {
  List<Question> questionList;
  bool questionsRetrieved = false;
  void getQuestions(HeadToHeadGame game) async {
    await game.getQuestions();
    questionList = game.questions;
    questionsRetrieved = true;
    notifyListeners();
  }
}