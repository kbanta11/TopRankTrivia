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

class TriviaBlitzPage extends StatelessWidget {
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
                                  title: Text('Trivia Blitz', style: TextStyle(fontSize: 28, color: Colors.white),)
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
                            child: Center(child: Text('There are no Trivia Blitz games available right now.', style: TextStyle(fontSize: 18)))
                        ),
                        BottomNavBar(selected: 'blitz',),
                      ],
                    )
                ),
              );
            }
        )
    );
  }
}