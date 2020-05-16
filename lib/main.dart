import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flushbar/flushbar.dart';
import 'package:trivia_game/AdminPage.dart';
import 'package:trivia_game/Blitz.dart';
import 'package:trivia_game/db_services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:marquee/marquee.dart';
import 'LoginPage.dart';
import 'AddLadder.dart';
import 'AdminPage.dart';
import 'LadderPage.dart';
import 'StorePage.dart';
import 'HeadToHead.dart';
import 'HowToDialog.dart';
import 'MessagesDialog.dart';
import 'models.dart';

const String AD_MOB_APP_ID = 'ca-app-pub-5887055143640982~1017841422';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  FirebaseMessaging _fcm = FirebaseMessaging();
  StreamSubscription iosSubscription;


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    FirebaseAdMob.instance.initialize(appId: AD_MOB_APP_ID);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    FirebaseAnalytics analytics = FirebaseAnalytics();
    if (Platform.isIOS) {
      _fcm.requestNotificationPermissions(const IosNotificationSettings(sound: true, badge: true, alert: true));
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        // save the token  OR subscribe to a topic here
        _fcm.getToken().then((token) {
          print(token);
        });
      });
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        Flushbar(
          backgroundColor: Colors.deepOrangeAccent,
          title:  message['notification']['title'],
          message:  message['notification']['body'],
          duration:  Duration(seconds: 4),
          margin: EdgeInsets.all(8),
          borderRadius: 8,
          flushbarPosition: FlushbarPosition.TOP,
        )..show(context);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // TODO optional
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        // TODO optional
      },
    );
    return MultiProvider(
      providers: [
        StreamProvider<FirebaseUser>.value(value: FirebaseAuth.instance.onAuthStateChanged),
        ChangeNotifierProvider<LadderListProvider>(create: (context) => LadderListProvider(),),
      ],
      child: WillPopScope(
        onWillPop: () => Future.value(false),
        child: Consumer<FirebaseUser>(
            builder: (context, currentUser, _) {
              return StreamProvider(
                create: (context) => DBService().streamUserDoc(currentUser),
                child: MaterialApp(
                  title: 'TriviaGame',
                  theme: ThemeData(
                    textTheme: GoogleFonts.straitTextTheme(Theme.of(context).textTheme)
                  ),
                  home: currentUser == null ? LoginPage() : MyHomePage(title: 'TriviaGame'),
                ),
              );
            }),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    FirebaseUser currentUser = Provider.of<FirebaseUser>(context);
    LadderListProvider ladderListProvider = Provider.of<LadderListProvider>(context);
    return StreamProvider<User>(
      create:(context) => DBService().streamUserDoc(currentUser),
      child: Consumer<User>(
        builder: (context, userDoc, _) {
          return WillPopScope(
            onWillPop: () => Future.value(false),
            child: Scaffold(
              body: Center(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      currentUser == null ? Center(child: CircularProgressIndicator(),) : StreamProvider<User>.value(
                        value: DBService().streamUserDoc(currentUser),
                        child: Consumer<User>(
                          builder: (context, userDoc, _) {
                            print('User: ${userDoc}');
                            if(userDoc == null)
                              return Center(child: CircularProgressIndicator(),);
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              height: 260,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
                                image: DecorationImage(
                                  image: AssetImage('assets/images/topPanelbg.png'),
                                  fit: BoxFit.fill
                                )
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  AppBar(
                                    elevation: 0,
                                    backgroundColor: Colors.transparent,
                                    leading: TopMenu(),
                                    // Here we take the value from the MyHomePage object that was created by
                                    // the App.build method, and use it to set our appbar title.
                                    title: Text('Top Trivia', style: TextStyle(fontSize: 30, color: Colors.white),),
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              width: 120,
                                              height: 45,
                                              child: Stack(
                                                children: <Widget>[
                                                  Align(
                                                    alignment: Alignment.centerRight,
                                                    child: Container(
                                                        width: 100,
                                                        height: 35,
                                                        decoration: BoxDecoration(
                                                          color: Colors.black38,
                                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                                        ),
                                                      child: Text('${userDoc.laddersWon}', style: TextStyle(fontSize: 26, color: Colors.white),),
                                                      alignment: Alignment.center,
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Container(
                                                        width: 45,
                                                        height: 45,
                                                        decoration: BoxDecoration(
                                                            image: DecorationImage(
                                                                image: AssetImage('assets/images/TrophyIcon.png'),
                                                              fit: BoxFit.fill
                                                            )
                                                        )
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 15),
                                            Container(
                                              width: 120,
                                              height: 45,
                                              child: Stack(
                                                children: <Widget>[
                                                  Align(
                                                    alignment: Alignment.centerRight,
                                                    child: Container(
                                                        width: 100,
                                                        height: 35,
                                                        decoration: BoxDecoration(
                                                          color: Colors.black38,
                                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                                        ),
                                                      child: Text('${userDoc.laddersPlaced}', style: TextStyle(fontSize: 26, color: Colors.white),),
                                                      alignment: Alignment.center,
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Container(
                                                        width: 45,
                                                        height: 45,
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
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        height: 125,
                                        width: 125,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: userDoc.photoUrl != null ? NetworkImage(userDoc.photoUrl) : AssetImage('assets/images/ProfilePicPlaceholder.png'),
                                            fit: BoxFit.fill
                                          ),
                                          shape: userDoc.photoUrl != null ? BoxShape.circle : BoxShape.rectangle,
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              width: 120,
                                              height: 45,
                                              child: Stack(
                                                children: <Widget>[
                                                  Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Container(
                                                        width: 100,
                                                        height: 35,
                                                        decoration: BoxDecoration(
                                                          color: Colors.black38,
                                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                                        ),
                                                      child: Text('${userDoc != null ? Helper().formatNumber(userDoc.coins) : ''}', style: TextStyle(fontSize: 26, color: Colors.white), textAlign: TextAlign.right,),
                                                      alignment: Alignment.centerRight,
                                                      padding: EdgeInsets.only(right: 25),
                                                      //alignment: FractionalOffset(0.2, 0.5),
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment: Alignment.centerRight,
                                                    child: Container(
                                                        width: 45,
                                                        height: 45,
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
                                            SizedBox(height: 15),
                                            Container(
                                              width: 120,
                                              height: 45,
                                              child: Stack(
                                                children: <Widget>[
                                                  Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Container(
                                                        width: 100,
                                                        height: 35,
                                                        decoration: BoxDecoration(
                                                          color: Colors.black38,
                                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                                        ),
                                                      child: Text('${userDoc.bars}', style: TextStyle(fontSize: 26, color: Colors.white), textAlign: TextAlign.right,),
                                                      alignment: Alignment.centerRight,
                                                      padding: EdgeInsets.only(right: 25),
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment: Alignment.centerRight,
                                                    child: Container(
                                                        width: 45,
                                                        height: 45,
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
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(15, 5, 15, 15),
                                        child: Text('${userDoc.getDisplayName()}', style: TextStyle(fontSize: 30, color: Colors.white),),
                                      ),
                                      Expanded(
                                        child: Container(),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(8, 5, 8, 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            DropdownButtonHideUnderline(
                                child: Container(
                                  height: 35,
                                  padding: EdgeInsets.only(left: 5),
                                  decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(25)),
                                      side: BorderSide(
                                        color: Colors.deepOrangeAccent,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: DropdownButton(
                                    value: ladderListProvider.filter,
                                    icon: Icon(Icons.arrow_drop_down, color: Colors.deepOrangeAccent,),
                                    items: <String>['Live', 'My Ladders', 'Upcoming', 'Complete'].map((value) {
                                      return DropdownMenuItem(
                                        value: value,
                                        child: Text(value, style: TextStyle(fontSize: 16, color: Colors.deepOrangeAccent), textAlign: TextAlign.right,),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      ladderListProvider.changeFilter(val);
                                    },
                                  ),
                                )
                            )
                          ],
                        ),
                      ),
                      Expanded(
                          child: Container(
                            child: StreamProvider<List<Ladder>>.value(
                              value: DBService().streamLadders(filter: ladderListProvider.filter, userId: currentUser != null ? currentUser.uid : null),
                              child: Consumer<List<Ladder>>(
                                builder: (context, ladderList, _) {
                                  if(ladderList == null)
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  if(ladderListProvider.filter == 'Live') {
                                    ladderList = ladderList.where((ladder) => ladder.startDate.isBefore(DateTime.now())).toList();
                                    ladderList.sort((a, b) => a.endDate.compareTo(b.endDate));
                                  }
                                  if(ladderListProvider.filter == 'Complete') {
                                    ladderList.sort((a, b) => b.endDate.compareTo(a.endDate));
                                  }
                                  if(ladderListProvider.filter == 'My Ladders') {
                                    ladderList.sort((a, b) => b.endDate.compareTo(a.endDate));
                                  }
                                  return ListView(
                                    children: ladderList.map((ladder)=> Column(
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                                          child: Container(
                                            width: MediaQuery.of(context).size.width,
                                            //height: 120,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: AssetImage('assets/images/LadderTilebg.png'),
                                                fit: BoxFit.fill
                                              )
                                            ),
                                            child: InkWell(
                                              child: Padding(
                                                padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: <Widget>[
                                                          Container(
                                                            width: MediaQuery.of(context).size.width - 170,
                                                            height: 25,
                                                            child: Text('${ladder.title}    ', style: TextStyle(fontSize: 24), overflow: TextOverflow.ellipsis,),
                                                          ),
                                                          Text('${Helper().dateToString(ladder.startDate)}', style: TextStyle(fontFamily: 'Sans'),),
                                                          Text('${Helper().dateToString(ladder.endDate)}', style: TextStyle(fontFamily: 'Sans'),),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                            children: <Widget>[
                                                              Row(
                                                                children: <Widget>[
                                                                  FaIcon(FontAwesomeIcons.users),
                                                                  SizedBox(width: 5),
                                                                  Text(ladder.numGames == null ? '0' : ladder.numGames.toString(), style: TextStyle(
                                                                    fontSize: 18
                                                                  ),),
                                                                ]
                                                              ),
                                                              Row(
                                                                children: <Widget>[
                                                                  FaIcon(FontAwesomeIcons.clock),
                                                                  SizedBox(width: 5),
                                                                  Text('${ladder.respawnTime.inMinutes} min.', style: TextStyle(
                                                                      fontSize: 18
                                                                  ),)
                                                                ]
                                                              )
                                                            ]
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: <Widget>[
                                                        Container(
                                                            height: 40,
                                                            width: 120,
                                                            child: Stack(
                                                              children: <Widget>[
                                                                Align(
                                                                  alignment: ladder.type == 'coins' ? Alignment.topLeft : Alignment.centerLeft,
                                                                  child: Container(
                                                                    width: 80,
                                                                    height: 35,
                                                                    decoration: BoxDecoration(
                                                                        color: Colors.black12,
                                                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15))
                                                                    ),
                                                                    child: Text('${Helper().formatNumber(ladder.entryFee)}', style: TextStyle(fontSize: 22), textAlign: TextAlign.right,),
                                                                    alignment: Alignment.centerRight,
                                                                    padding: EdgeInsets.only(right: 15),
                                                                  ),
                                                                ),
                                                                Align(
                                                                  alignment: Alignment.centerRight,
                                                                  child: Container(
                                                                    height: 60,
                                                                    width: 60,
                                                                    decoration: BoxDecoration(
                                                                        image: DecorationImage(
                                                                            image: AssetImage(ladder.type == 'coins' ? 'assets/images/Coins.png' : 'assets/images/GoldBarIcon.png')
                                                                        )
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            )
                                                        ),
                                                        SizedBox(height: 5,),
                                                        Container(
                                                            height: 40,
                                                            width: 120,
                                                            child: Stack(
                                                              children: <Widget>[
                                                                Align(
                                                                  alignment: Alignment.topLeft,
                                                                  child: Container(
                                                                    width: 90,
                                                                    height: 35,
                                                                    decoration: BoxDecoration(
                                                                        color: Colors.black12,
                                                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15))
                                                                    ),
                                                                    alignment: Alignment.centerRight,
                                                                    padding: EdgeInsets.only(right: ladder.numLives < 1 ? 22 : 25),
                                                                    child: Text('${ladder.numLives < 1 ? 'No Limit' : ladder.numLives}', style: TextStyle(fontSize: ladder.numLives < 1 ? 13 : 22), textAlign: TextAlign.right,),
                                                                  ),
                                                                ),
                                                                Align(
                                                                  alignment: Alignment.centerRight,
                                                                  child: Container(
                                                                    height: 50,
                                                                    width: 50,
                                                                    decoration: BoxDecoration(
                                                                        image: DecorationImage(
                                                                            image: AssetImage('assets/images/Heart.png')
                                                                        )
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            )
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                              onTap: () {
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => LadderPage(ladder)));
                                              },
                                            ),
                                          )
                                        ),
                                      ],
                                    )).toList(),
                                  );
                                },
                              ),
                            ),
                          )
                      ),
                      BottomNavBar(context: context, selected: 'ladders',)
                    ],
                  ),
                ),
              ), // This trailing comma makes auto-formatting nicer for build methods.
            ),
          );
        },
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  BuildContext context;
  String selected;

  BottomNavBar({this.context, this.selected});

  @override
  build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        //Ladders
        Expanded(
          child: Container(
            padding: EdgeInsets.fromLTRB(2, 5, 2, 5),
            color: selected == 'ladders' ? Colors.cyan : Colors.transparent,
            child: Center(
                child: FlatButton(
                  color: Colors.transparent,
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: 28,
                        width: 28,
                        decoration: BoxDecoration(
                            image: DecorationImage(image: AssetImage('assets/images/LadderIcon-${selected == 'ladders' ? 'White' : 'Blue'}.png'))
                        ),
                      ),
                      SizedBox(width: 7),
                      Text('Ladders', style: TextStyle(fontSize: 16, color: selected == 'ladders' ? Colors.white : Colors.cyan),)
                    ],
                  ),
                  //shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage()));
                  },
                )
            ),
          )
        ),
        //1v1
        Expanded(
          child: Container(
            padding: EdgeInsets.fromLTRB(2, 5, 2, 5),
            color: selected == 'head' ? Colors.cyan : Colors.transparent,
            child: Center(
              child: FlatButton(
                child: Column(
                    children: <Widget>[
                      Icon(Icons.people, size: 30, color: selected == 'head' ? Colors.white : Colors.cyan,),
                      Text('1 v 1', style: TextStyle(fontSize: 16, color: selected == 'head' ? Colors.white : Colors.cyan))
                    ]
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HeadToHeadPage()));
                },
              ),
            )
          )
        ),
        //Blitz
        Expanded(
          child: Container(
            padding: EdgeInsets.fromLTRB(2, 5, 2, 5),
            color: selected == 'blitz' ? Colors.cyan : Colors.transparent,
            child: Center(
                child: FlatButton(
                  child: Column(
                    children: <Widget>[
                      //Icon(Icons.offline_bolt),
                      FaIcon(FontAwesomeIcons.bolt, color: selected == 'blitz' ? Colors.white : Colors.cyan,),
                      Text('Blitz', style: TextStyle(fontSize: 16, color: selected == 'blitz' ? Colors.white : Colors.cyan))
                    ],
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TriviaBlitzPage()));
                  },
                )
            ),
          )
        ),
        //Store
        Expanded(
          child: Container(
            padding: EdgeInsets.fromLTRB(2, 5, 2, 5),
            color: selected == 'store' ? Colors.cyan : Colors.transparent,
            child: Center(
                child: FlatButton(
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: 28,
                        width: 28,
                        decoration: BoxDecoration(
                            image: DecorationImage(image: AssetImage('assets/images/ShoppingCart-${selected == 'store' ? 'White': 'Blue'}.png'))
                        ),
                      ),
                      SizedBox(width: 7),
                      Text('Store', style: TextStyle(fontSize: 16, color: selected == 'store' ? Colors.white : Colors.cyan))
                    ],
                  ),
                  //shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                  color: Colors.transparent,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => StorePage()));
                  },
                )
            )
          ),
        ),
      ],
    );
  }
}

class TopMenu extends StatelessWidget {
  @override
  build(BuildContext context) {
    User currentUser = Provider.of<User>(context);

    return currentUser == null ? Container() :StreamProvider<List<Message>>.value(
        value: DBService().streamUserMessages(currentUser),
        child: Consumer<List<Message>>(
          builder: (context, messageList, _) {
            return PopupMenuButton(
              child: Padding(
                padding: EdgeInsets.fromLTRB(15, 10, 10, 10),
                child: Stack(
                  children: <Widget>[
                    Image.asset('assets/images/menu-btn.png', height: 50, width: 50,),
                    messageList != null && messageList.where((msg) => !msg.isRead).length > 0 ? Align(
                      alignment: Alignment.topRight,
                      child: FaIcon(FontAwesomeIcons.solidComment, color: Colors.amberAccent, size: 20,),
                    ) : Container(),
                  ],
                ),
              ),
              itemBuilder: (context) {
                List<PopupMenuItem> items = List<PopupMenuItem>();

                items.add(PopupMenuItem(
                  child: Text('Ladders'),
                  value: 'ladders',
                ));
                items.add(PopupMenuItem(
                    child: Row(
                      children: <Widget>[
                        Text('Messages'),
                        SizedBox(width: 10,),
                        messageList != null && messageList.where((msg) => !msg.isRead).length > 0 ? FaIcon(FontAwesomeIcons.solidComment, color: Colors.amberAccent, size: 20) : Container(),
                      ],
                    ),
                    value: 'messages'
                ));
                items.add(PopupMenuItem(
                  child: Text('How To Play'),
                  value: 'howto',
                ));
                items.add(PopupMenuItem(
                  child: Text('Head to Head'),
                  value: 'head',
                ));
                if(currentUser.isAdmin)
                  items.add(PopupMenuItem(
                    child: Text('Admin'),
                    value: 'admin',
                  ));
                items.add(PopupMenuItem(
                  child: Text('Logout'),
                  value: 'logout',
                ));
                return items;
              },
              onSelected: (value) {
                if(value == 'logout') {
                  DBService().logout();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                }
                if(value == 'ladders')
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage()));
                if(value == 'admin')
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AdminPage()));
                if(value == 'head')
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HeadToHeadPage()));
                if(value == 'howto')
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return HowToDialog();
                      }
                  );
                if(value == 'messages')
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return MessagesDialog(currentUser);
                      }
                  );
              },
            );
          },
        ),
    );
  }
}

class LadderListProvider extends ChangeNotifier {
  String filter = 'Live';

  void changeFilter(String value) {
    filter = value;
    notifyListeners();
  }
}