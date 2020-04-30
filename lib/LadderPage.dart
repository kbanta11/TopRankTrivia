import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trivia_game/main.dart';
import 'LoginPage.dart';
import 'db_services.dart';
import 'models.dart';
import 'PlayPage.dart';
import 'StorePage.dart';

class LadderPage extends StatelessWidget {
  Ladder ladder;

  LadderPage(this.ladder);

  @override
  build(BuildContext context) {
    FirebaseUser currentUser = Provider.of<FirebaseUser>(context);
    return StreamProvider(
      create: (context) => DBService().streamUserDoc(currentUser),
      child: Consumer<User>(
        builder: (context, user, _) {
          return WillPopScope(
            onWillPop: () => Future.value(false),
            child: Scaffold(
              body: currentUser == null ? Container() : MultiProvider(
                providers: [
                  StreamProvider<Game>.value(value: DBService().streamGame(ladder.id, currentUser.uid).handleError((err) => print(err))),
                  StreamProvider<List<Game>>.value(value: DBService().streamGames(ladder: ladder))
                ],
                child: Consumer<Game>(
                  builder: (context, game, _) {
                    List<Game> gamesList = Provider.of<List<Game>>(context);
                    if(gamesList != null)
                      gamesList.sort((a, b) => b.totalScore.compareTo(a.totalScore));
                    return Center(
                      child: Column(
                          children: <Widget>[
                            Container(
                              //height: 200,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage('assets/images/topPanelbg.png'),
                                    fit: BoxFit.fill
                                  )
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    AppBar(
                                      leading: TopMenu(),
                                      title: Text('${ladder.title}', style: TextStyle(color: Colors.white)),
                                      backgroundColor: Colors.transparent,
                                      elevation: 0,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
                                      child: Container(
                                        width: MediaQuery.of(context).size.width - 20,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage('assets/images/EndDateBackground.png'),
                                            fit: BoxFit.fill
                                          )
                                        ),
                                        child: Center(
                                          child: Container(
                                            padding: EdgeInsets.fromLTRB(5, 5, 5, 10),
                                              child: Text('${ladder.endDate.compareTo(DateTime.now()) < 0 ? 'Ended:' : 'Ends:'} ${Helper().dateToString(ladder.endDate)}!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18, fontFamily: 'Sans'), textAlign: TextAlign.center)
                                          ),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          height: 45,
                                          width: 110,
                                          child: Stack(
                                            children: <Widget>[
                                              Align(
                                                alignment: Alignment.centerRight,
                                                child: Container(
                                                  height: 35,
                                                  width: 90,
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.only(topRight: Radius.circular(15), bottomRight: Radius.circular(15)),
                                                      color: Colors.black38
                                                  ),
                                                  alignment: Alignment.centerLeft,
                                                  padding: EdgeInsets.only(left: 30),
                                                  child: Text('${game == null ? '0' : game.totalScore}', style: TextStyle(fontSize: 20, color: Colors.white),),
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Container(
                                                  height: 45,
                                                  width: 45,
                                                  decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                          image: AssetImage('assets/images/ScoreStarIcon.png'),
                                                          fit: BoxFit.fill
                                                      )
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Container(
                                          height: 45,
                                          width: 110,
                                          child: Stack(
                                            children: <Widget>[
                                              Align(
                                                alignment: Alignment.centerRight,
                                                child: Container(
                                                  height: 35,
                                                  width: 90,
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.only(topRight: Radius.circular(15), bottomRight: Radius.circular(15)),
                                                      color: Colors.black38
                                                  ),
                                                  alignment: Alignment.centerLeft,
                                                  padding: EdgeInsets.only(left: 30),
                                                  child: Text('${game == null ? '' : game.livesRemaining < 0 ? 'No Limit' : game.livesRemaining}', style: TextStyle(fontSize: game != null && game.livesRemaining < 0 ? 14 : 20, color: Colors.white), textAlign: game != null && game.livesRemaining < 0 ? TextAlign.center : TextAlign.left,),
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Container(
                                                  height: 45,
                                                  width: 45,
                                                  decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                          image: AssetImage('assets/images/HeartIcon.png'),
                                                          fit: BoxFit.fill
                                                      )
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Container(
                                          height: 45,
                                          width: 110,
                                          child: Stack(
                                            children: <Widget>[
                                              Align(
                                                alignment: Alignment.centerRight,
                                                child: Container(
                                                  height: 35,
                                                  width: 90,
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.only(topRight: Radius.circular(15), bottomRight: Radius.circular(15)),
                                                      color: Colors.black38
                                                  ),
                                                  alignment: Alignment.centerLeft,
                                                  padding: EdgeInsets.only(left: 30),
                                                  child: Text('${gamesList == null || game == null ? '-' : '${gamesList.map((game) => game.id).toList().indexOf(game.id) + 1}'}', style: TextStyle(fontSize: 20, color: Colors.white)),
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Container(
                                                  height: 45,
                                                  width: 45,
                                                  decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                          image: AssetImage('assets/images/MedalIcon.png'),
                                                          fit: BoxFit.fill
                                                      )
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Center(
                                      child: Text('Current Pot: ${gamesList != null ? Helper().formatNumber(gamesList.length * ladder.entryFee) : '0'}', style: TextStyle(fontSize: 24, color: Colors.white)),
                                    ),
                                    SizedBox(height: 15,),
                                  ],
                                )
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                OutlineButton(
                                  color: Colors.cyan,
                                  borderSide: BorderSide(color: Colors.cyan, width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(25))
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        width: 25,
                                        height: 25,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage('assets/images/LadderIcon-Blue.png')
                                          )
                                        )
                                      ),
                                      SizedBox(width: 5),
                                      Text('ladders', style: TextStyle(color: Colors.cyan, fontSize: 22),)
                                    ],
                                  ),
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage()));
                                  },
                                ),
                                SizedBox(width: 15),
                                OutlineButton(
                                  color: Colors.cyan,
                                  borderSide: BorderSide(color: Colors.cyan, width: 2),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(25))
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                          width: 25,
                                          height: 25,
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: AssetImage('assets/images/ShoppingCart-Blue.png')
                                              )
                                          )
                                      ),
                                      SizedBox(width: 5),
                                      Text('store', style: TextStyle(color: Colors.cyan, fontSize: 22),)
                                    ],
                                  ),
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => StorePage()));
                                  },
                                ),
                              ],
                            ),
                            Expanded(
                              child: gamesList == null ? Container() : ListView(
                                children: gamesList.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  Game gm = entry.value;
                                  return Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                                        child: Container(
                                          height: 90,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage('assets/images/LadderTilebg.png'),
                                              fit: BoxFit.fill
                                            )
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 15, right: 15),
                                            child: Row(
                                              children: <Widget>[
                                                Container(
                                                  height: 60,
                                                  width: 60,
                                                  decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                          image: AssetImage('assets/images/RankBackground.png')
                                                      )
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text('${index + 1}', style: TextStyle(fontSize: 28, color: Colors.white),),
                                                ),
                                                SizedBox(width: 8),
                                                Expanded(child: Text('${User().getDisplayName(nm: gm.userDisplayname)}', style: TextStyle(fontSize: 20, fontFamily: 'Sans')),),
                                                SizedBox(width: 8),
                                                Container(
                                                  width: 120,
                                                  height: 45,
                                                  child: Stack(
                                                    children: <Widget>[
                                                      Align(
                                                        alignment: Alignment.centerLeft,
                                                        child: Container(
                                                            height: 35,
                                                            width: 110,
                                                            decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                                                                color: Colors.black12
                                                            ),
                                                          alignment: Alignment.centerRight,
                                                          padding: EdgeInsets.only(right: 38),
                                                          child: Text('${gm != null ? gm.totalScore ?? '0' : '0'}', style: TextStyle(fontSize: 20, fontFamily: 'Sans'),),
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment: Alignment.centerRight,
                                                        child: Container(
                                                            width: 45,
                                                            height: 45,
                                                            decoration: BoxDecoration(
                                                                image: DecorationImage(
                                                                  image: AssetImage('assets/images/ScoreStarIcon.png'),
                                                                  fit: BoxFit.fill,
                                                                )
                                                            )
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          alignment: Alignment.centerLeft,
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                            Container(
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.cyan,
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    height: 45,
                                    width: 120,
                                    child: Stack(
                                      children: <Widget>[
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            width: 110,
                                            height: 35,
                                            decoration: BoxDecoration(
                                              color: Colors.black38,
                                              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20))
                                            ),
                                            alignment: Alignment.centerRight,
                                            padding: EdgeInsets.only(right: 35),
                                            child: Text('${user != null ? Helper().formatNumber(user.coins) : ''}', style: TextStyle(fontSize: 20, color: Colors.white),),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Container(
                                            width: 45,
                                            height: 45,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: AssetImage('assets/images/CoinIcon.png')
                                              )
                                            )
                                          )
                                        )
                                      ],
                                    )
                                  ),
                                  SizedBox(width: 8),
                                  Container(
                                      height: 45,
                                      width: 100,
                                      child: Stack(
                                        children: <Widget>[
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                                width: 80,
                                                height: 35,
                                                decoration: BoxDecoration(
                                                    color: Colors.black38,
                                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20))
                                                ),
                                              alignment: Alignment.centerRight,
                                              padding: EdgeInsets.only(right: 25),
                                              child: Text('${user != null ? user.bars: ''}', style: TextStyle(fontSize: 20, color: Colors.white)),
                                            ),
                                          ),
                                          Align(
                                              alignment: Alignment.centerRight,
                                              child: Container(
                                                  width: 45,
                                                  height: 45,
                                                  decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                          image: AssetImage('assets/images/GoldBarIcon.png')
                                                      )
                                                  ),
                                              )
                                          )
                                        ],
                                      )
                                  ),
                                  SizedBox(width: 8),
                                  Container(
                                    width: 120,
                                    alignment: Alignment.centerRight,
                                    child: ladder.endDate.compareTo(DateTime.now()) < 0 ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text('Congrats', style: TextStyle(fontSize: 16, color: Colors.white),),
                                        Text('${gamesList != null && gamesList.length > 0 ? ' ${User().getDisplayName(nm: gamesList[0].userDisplayname)}!' : ''}', style: TextStyle(fontSize: 16, color: Colors.white),)
                                      ],
                                    ) : game == null ? Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage('assets/images/PlayBtn.png'),
                                          fit: BoxFit.fill
                                        )
                                      ),
                                      child: InkWell(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text('Join', style: TextStyle(fontSize: 18, color: Colors.white)),
                                            SizedBox(width: 5,),
                                            Container(
                                              width: 25,
                                              height: 25,
                                              decoration: BoxDecoration(
                                                  image: DecorationImage(image: AssetImage(ladder.type == 'coins' ? 'assets/images/Coins.png' : 'assets/images/GoldBar.png'))
                                              ),
                                            ),
                                            SizedBox(width: 5,),
                                            Text('${ladder.entryFee}', style: TextStyle(fontSize: 18, color: Colors.white),)
                                          ],
                                        ),
                                        onTap: () {
                                          int entry = ladder.type == 'coins' ? user.coins : user.bars;
                                          if(ladder.entryFee > entry) {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return SimpleDialog(
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                                                    //title: Text('Not Enough Coins'),
                                                    children: <Widget>[
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                        children: <Widget>[
                                                          IconButton(
                                                            icon: Text('X', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                                                            onPressed: () {
                                                              Navigator.of(context).pop();
                                                            },
                                                          )
                                                        ],
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets.fromLTRB(20, 10, 20, 25),
                                                        child: Center(child: Text('You Do Not Have Enough ${ladder.type == 'coins' ? 'Coins' : 'Gold Bars'}!', style: TextStyle(fontSize: 18),)),
                                                      ),
                                                    ],
                                                  );
                                                }
                                            );
                                          } else {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return JoinDialog(ladder);
                                                }
                                            );
                                          }
                                        },
                                      ),
                                    ) : game.livesRemaining == 0 ? Container(height: 40) : StreamProvider<Duration>(
                                      create: (context) => game.timeSinceLastQuestion(),
                                      child: Consumer<Duration>(
                                        builder: (context, timeSinceLast, _) {
                                          if(timeSinceLast == null)
                                            return Container(height: 40);
                                          if(!game.isAlive && timeSinceLast.compareTo(ladder.respawnTime) < 0) {
                                            Duration timeLeft = Duration(seconds: ladder.respawnTime.inSeconds - timeSinceLast.inSeconds);
                                            return Text('${timeLeft.inHours > 0 ? '${timeLeft.inHours}:' : ''}${timeLeft.inMinutes.remainder(60).toString().padLeft(2, '0')}:${timeLeft.inSeconds.remainder(60).toString().padLeft(2, '0')}', style: TextStyle(fontSize: 24, color: Colors.white),);
                                          }
                                          if(ladder.startDate.compareTo(DateTime.now()) >= 0){
                                            print(DateTime.now().compareTo(ladder.startDate));
                                            return Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text('Ladder Starts:', style: TextStyle(fontSize: 14, color: Colors.white),),
                                                Text('${DateFormat('MMMM d, y\nh:mm a').format(ladder.startDate)}', style: TextStyle(fontSize: 14, color: Colors.white),)
                                              ],
                                            );
                                          }
                                          return Container(
                                            height: 40,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: AssetImage('assets/images/PlayBtn.png'),
                                                fit: BoxFit.fill
                                              )
                                            ),
                                            alignment: Alignment.center,
                                            child: InkWell(
                                              child: Padding(
                                                padding: EdgeInsets.only(left: 8, right: 8),
                                                child: Text('Play Game', style: TextStyle(fontSize: 18, color: Colors.white),),
                                              ),
                                              onTap: () {
                                                Navigator.push(context, MaterialPageRoute(builder: (context) {
                                                  return PlayPage(ladder: ladder);
                                                }));
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ]
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class JoinDialog extends StatelessWidget {
  Ladder ladder;

  JoinDialog(this.ladder);

  @override
  build(BuildContext context) {
    User currentUser = Provider.of<User>(context);
    return SimpleDialog(
      elevation: 10,
      title: Center(
        child: Text('Join Ladder?', style: TextStyle(fontSize: 24),),
      ),
      contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
      children: <Widget>[
        Text('${ladder.title}', style: TextStyle(fontSize: 24), textAlign: TextAlign.center,),
        SizedBox(height: 15,),
        ladder.prize != null && ladder.hasPrize ? Text('Prize: ${ladder.prize}', style: TextStyle(fontSize: 20), textAlign: TextAlign.center,) : Container(),
        ladder.prize != null && ladder.hasPrize ? SizedBox(height: 15,) : Container(),
        Text('Are you sure you would like to join this ladder?', style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
        SizedBox(height: 15,),
        Text('Start:', style: TextStyle(fontSize: 18)),
        Text('${Helper().dateToString(ladder.startDate)}', style: TextStyle(fontSize: 18)),
        SizedBox(height: 10),
        Text('End:', style: TextStyle(fontSize: 18)),
        Text('${Helper().dateToString(ladder.endDate)}', style: TextStyle(fontSize: 18)),
        SizedBox(height: 10),
        Text('Number of Lives: ${ladder.numLives < 1 ? 'Unlimited' : ladder.numLives.toString()}', style: TextStyle(fontSize: 18)),
        Text('Respawn Time: ${ladder.respawnTime.inMinutes == 0 ? 'Instant Respawn' : '${ladder.respawnTime.inMinutes} minutes'}', style: TextStyle(fontSize: 18)),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))
              ),
              child: Text('Cancel', style: TextStyle(fontSize: 18)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              color: Colors.cyan,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Join', style: TextStyle(fontSize: 18, color: Colors.white)),
                  SizedBox(width: 5,),
                  Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                        image: DecorationImage(image: AssetImage(ladder.type == 'coins' ? 'assets/images/Coins.png' : 'assets/images/GoldBar.png'))
                    ),
                  ),
                  SizedBox(width: 5,),
                  Text('${ladder.entryFee}', style: TextStyle(fontSize: 18, color: Colors.white),)
                ],
              ),
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Center(child: CircularProgressIndicator());
                  }
                );
                Game _game = await DBService().createGame(ladder: ladder, user: currentUser, type: ladder.type).then((Game game) {
                  Navigator.of(context).pop();
                  return game;
                });
                if(ladder.startDate.compareTo(DateTime.now()) < 0)
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PlayPage(ladder: ladder)));
                else {
                  Navigator.of(context).pop();
                }
              },
            )
          ],
        )
      ],
    );
  }
}