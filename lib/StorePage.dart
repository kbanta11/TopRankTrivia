import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models.dart';
import 'main.dart';
import 'package:intl/intl.dart';
import 'db_services.dart';

class StorePage extends StatelessWidget {
  @override
  build(BuildContext context) {
    FirebaseUser currentUser = Provider.of<FirebaseUser>(context);
    return StreamProvider<User>(
      create: (context) => DBService().streamUserDoc(currentUser),
      child: Consumer<User>(
        builder: (context, user, _) {
          return Scaffold(
            body: Column(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
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
                        title: Text('Store', style: TextStyle(fontSize: 28, color: Colors.white),)
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 15, 10, 25),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    OutlineButton(
                      color: Colors.cyan,
                      borderSide: BorderSide(width: 2, color: Colors.cyan),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            height: 25,
                            width: 25,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/LadderIcon-Blue.png')
                              )
                            )
                          ),
                          SizedBox(width: 5),
                          Text('ladders', style: TextStyle(color: Colors.cyan, fontSize: 22))
                        ],
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage()));
                      },
                    ),
                    SizedBox(width: 25),
                    FlatButton(
                      color: Colors.cyan,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            height: 25,
                            width: 25,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/ShoppingCart-White.png')
                              )
                            )
                          ),
                          SizedBox(width: 5),
                          Text('store', style: TextStyle(color: Colors.white, fontSize: 22))
                        ],
                      ),
                      onPressed: () {

                      },
                    )
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: Container(
                                child: Container(
                                  height: 160,
                                  width: 150,
                                  child: Stack(
                                    children: <Widget>[
                                      Container(
                                        height: 150,
                                        width: 150,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage('assets/images/StoreItembg.png'),
                                            fit: BoxFit.fill
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            SizedBox(height: 5),
                                            Container(
                                              width: 75,
                                              height: 75,
                                              decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      image: AssetImage('assets/images/Coins.png')
                                                  )
                                              ),
                                            ),
                                            SizedBox(height: 5,),
                                            Container(
                                              width: 120,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(Radius.circular(25)),
                                                color: Colors.black12
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Text('x'),
                                                  Text('100', style: TextStyle(fontSize: 24),)
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          width: 100,
                                          height: 35,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage('assets/images/StoreBuyButton-Green.png'),
                                              fit: BoxFit.fill
                                            )
                                          ),
                                          child: InkWell(
                                            child: Icon(Icons.ondemand_video, color: Colors.white,),
                                            onTap: () async {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return Center(
                                                    child: CircularProgressIndicator(),
                                                  );
                                                }
                                              );
                                              RewardedVideoAd.instance.listener = (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
                                                if(event == RewardedVideoAdEvent.rewarded) {
                                                  DBService().rewardCoins(user, 100);
                                                }
                                                if(event == RewardedVideoAdEvent.loaded) {
                                                  Navigator.of(context).pop();
                                                  RewardedVideoAd.instance.show();
                                                }
                                              };
                                              await RewardedVideoAd.instance.load(adUnitId: 'ca-app-pub-5887055143640982/1245405277' ?? RewardedVideoAd.testAdUnitId, targetingInfo: MobileAdTargetingInfo(testDevices: ['2A964E13F4310B0C3E0B13C89E35FD98','2EAF3CA98C317AA4482F535CA1094A23', 'F358A854E8C08E90BDD900D8B4B97846']));
                                            },
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: Container(
                                child: Container(
                                    height: 160,
                                    width: 150,
                                    child: Stack(
                                      children: <Widget>[
                                        Container(
                                          height: 150,
                                          width: 150,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage('assets/images/StoreItembg.png'),
                                                fit: BoxFit.fill
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              SizedBox(height: 5),
                                              Container(
                                                width: 75,
                                                height: 75,
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image: AssetImage('assets/images/Coins.png')
                                                    )
                                                ),
                                              ),
                                              SizedBox(height: 5,),
                                              Container(
                                                width: 120,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.all(Radius.circular(25)),
                                                    color: Colors.black12
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text('x'),
                                                    Text('1000', style: TextStyle(fontSize: 24),)
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            width: 100,
                                            height: 35,
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: AssetImage('assets/images/StoreBuyButton-Red.png'),
                                                    fit: BoxFit.fill
                                                )
                                            ),
                                            alignment: Alignment.center,
                                            child: InkWell(
                                              child: Text('Buy! \$0.99', style: TextStyle(color: Colors.white, fontSize: 16)),
                                              onTap: () {

                                              },
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: Container(
                                child: Container(
                                    height: 160,
                                    width: 150,
                                    child: Stack(
                                      children: <Widget>[
                                        Container(
                                          height: 150,
                                          width: 150,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage('assets/images/StoreItembg.png'),
                                                fit: BoxFit.fill
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              SizedBox(height: 5),
                                              Container(
                                                width: 75,
                                                height: 75,
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image: AssetImage('assets/images/Coins.png')
                                                    )
                                                ),
                                              ),
                                              SizedBox(height: 5,),
                                              Container(
                                                width: 120,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.all(Radius.circular(25)),
                                                    color: Colors.black12
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text('x'),
                                                    Text('5000', style: TextStyle(fontSize: 24),)
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            width: 100,
                                            height: 35,
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: AssetImage('assets/images/StoreBuyButton-Red.png'),
                                                    fit: BoxFit.fill
                                                )
                                            ),
                                            alignment: Alignment.center,
                                            child: InkWell(
                                              child: Text('Buy! \$3.99', style: TextStyle(color: Colors.white, fontSize: 16)),
                                              onTap: () {

                                              },
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: Container(
                                child: Container(
                                    height: 160,
                                    width: 150,
                                    child: Stack(
                                      children: <Widget>[
                                        Container(
                                          height: 150,
                                          width: 150,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage('assets/images/StoreItembg.png'),
                                                fit: BoxFit.fill
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              SizedBox(height: 5),
                                              Container(
                                                width: 75,
                                                height: 75,
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image: AssetImage('assets/images/Coins.png')
                                                    )
                                                ),
                                              ),
                                              SizedBox(height: 5,),
                                              Container(
                                                width: 120,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.all(Radius.circular(25)),
                                                    color: Colors.black12
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text('x'),
                                                    Text('10000', style: TextStyle(fontSize: 24),)
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            width: 100,
                                            height: 35,
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: AssetImage('assets/images/StoreBuyButton-Red.png'),
                                                    fit: BoxFit.fill
                                                )
                                            ),
                                            alignment: Alignment.center,
                                            child: InkWell(
                                              child: Text('Buy! \$7.99', style: TextStyle(color: Colors.white, fontSize: 16)),
                                              onTap: () {

                                              },
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: Container(
                                child: Container(
                                    height: 160,
                                    width: 150,
                                    child: Stack(
                                      children: <Widget>[
                                        Container(
                                          height: 150,
                                          width: 150,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage('assets/images/StoreItembg.png'),
                                                fit: BoxFit.fill
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              SizedBox(height: 5),
                                              Container(
                                                width: 75,
                                                height: 75,
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image: AssetImage('assets/images/GoldBar.png')
                                                    )
                                                ),
                                              ),
                                              SizedBox(height: 5,),
                                              Container(
                                                width: 120,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.all(Radius.circular(25)),
                                                    color: Colors.black12
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text('x'),
                                                    Text('1', style: TextStyle(fontSize: 24),)
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            width: 120,
                                            height: 35,
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: AssetImage(user != null && user.coins >= 50000 ? 'assets/images/StoreBuyButton-Green.png' : 'assets/images/StoreBuyButton-Red.png'),
                                                    fit: BoxFit.fill
                                                )
                                            ),
                                            alignment: Alignment.center,
                                            child: InkWell(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Text('Buy!', style: TextStyle(color: Colors.white, fontSize: 16)),
                                                  SizedBox(width: 5),
                                                  Container(
                                                    height: 20,
                                                    width: 20,
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                        image: AssetImage('assets/images/Coins.png')
                                                      )
                                                    )
                                                  ),
                                                  SizedBox(width: 5),
                                                  Text('50k', style: TextStyle(color: Colors.white, fontSize: 16))
                                                ],
                                              ),
                                              onTap: () {
                                                if(user != null && user.coins >= 50000)
                                                  showDialog(
                                                    context: context,
                                                    child: BuyDialog(type: 'bar', buyAmount: 1, buyWith: 'coins', price: 50000,),
                                                  );
                                              },
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: Container(
                                child: Container(
                                    height: 160,
                                    width: 150,
                                    child: Stack(
                                      children: <Widget>[
                                        Container(
                                          height: 150,
                                          width: 150,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage('assets/images/StoreItembg.png'),
                                                fit: BoxFit.fill
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              SizedBox(height: 5),
                                              Container(
                                                width: 75,
                                                height: 75,
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image: AssetImage('assets/images/GoldBar.png')
                                                    )
                                                ),
                                              ),
                                              SizedBox(height: 5,),
                                              Container(
                                                width: 120,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.all(Radius.circular(25)),
                                                    color: Colors.black12
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text('x'),
                                                    Text('3', style: TextStyle(fontSize: 24),)
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            width: 120,
                                            height: 35,
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: AssetImage(user != null && user.coins >= 125000 ? 'assets/images/StoreBuyButton-Green.png' : 'assets/images/StoreBuyButton-Red.png'),
                                                    fit: BoxFit.fill
                                                )
                                            ),
                                            alignment: Alignment.center,
                                            child: InkWell(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Text('Buy!', style: TextStyle(color: Colors.white, fontSize: 16)),
                                                  SizedBox(width: 5),
                                                  Container(
                                                      height: 20,
                                                      width: 20,
                                                      decoration: BoxDecoration(
                                                          image: DecorationImage(
                                                              image: AssetImage('assets/images/Coins.png')
                                                          )
                                                      )
                                                  ),
                                                  SizedBox(width: 5),
                                                  Text('125k', style: TextStyle(color: Colors.white, fontSize: 16))
                                                ],
                                              ),
                                              onTap: () {
                                                if(user != null && user.coins >= 125000)
                                                  showDialog(
                                                    context: context,
                                                    child: BuyDialog(type: 'bar', buyAmount: 1, buyWith: 'coins', price: 125000,),
                                                  );
                                              },
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: Container(
                                child: Container(
                                    height: 160,
                                    width: 150,
                                    child: Stack(
                                      children: <Widget>[
                                        Container(
                                          height: 150,
                                          width: 150,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage('assets/images/StoreItembg.png'),
                                                fit: BoxFit.fill
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              SizedBox(height: 5),
                                              Container(
                                                width: 75,
                                                height: 75,
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image: AssetImage('assets/images/GoldBar.png')
                                                    )
                                                ),
                                              ),
                                              SizedBox(height: 5,),
                                              Container(
                                                width: 120,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.all(Radius.circular(25)),
                                                    color: Colors.black12
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text('x'),
                                                    Text('10', style: TextStyle(fontSize: 24),)
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            width: 120,
                                            height: 35,
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: AssetImage(user != null && user.coins >= 400000 ? 'assets/images/StoreBuyButton-Green.png' : 'assets/images/StoreBuyButton-Red.png'),
                                                    fit: BoxFit.fill
                                                )
                                            ),
                                            alignment: Alignment.center,
                                            child: InkWell(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Text('Buy!', style: TextStyle(color: Colors.white, fontSize: 16)),
                                                  SizedBox(width: 5),
                                                  Container(
                                                      height: 20,
                                                      width: 20,
                                                      decoration: BoxDecoration(
                                                          image: DecorationImage(
                                                              image: AssetImage('assets/images/Coins.png')
                                                          )
                                                      )
                                                  ),
                                                  SizedBox(width: 5),
                                                  Text('400k', style: TextStyle(color: Colors.white, fontSize: 16))
                                                ],
                                              ),
                                              onTap: () {
                                                if(user != null && user.coins >= 400000)
                                                  showDialog(
                                                    context: context,
                                                    child: BuyDialog(type: 'bar', buyAmount: 1, buyWith: 'coins', price: 400000,),
                                                  );
                                              },
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: Container(
                                child: Container(
                                    height: 160,
                                    width: 150,
                                    child: Container()
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15)
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class BuyDialog extends StatelessWidget {
  String type;
  int buyAmount;
  String buyWith;
  int price;

  BuyDialog({
    this.type,
    this.buyAmount,
    this.buyWith,
    this.price,
  });

  @override
  build(BuildContext context) {
    User user= Provider.of<User>(context);
    return SimpleDialog(
      title: Center(child: Text('Buy $buyAmount $type${buyAmount > 1 ? 's' : ''}', style: TextStyle(fontSize: 24),),),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15)
      ),
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(10),
          child: Center(
            child: Text('Are you sure you would like to buy $buyAmount $type${buyAmount > 1 ? 's' : ''}?', style: TextStyle(fontSize: 18)),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            FlatButton(
              child: Text('Cancel', style: TextStyle(fontSize: 18)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/StoreBuyButton-Green.png'),
                  fit: BoxFit.fill
                )
              ),
              child: FlatButton(
                color: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
                child: Row(
                  children: <Widget>[
                    Text('Buy', style: TextStyle(fontSize: 18, color: Colors.white)),
                    SizedBox(width: 5,),
                    Container(
                      height: 28,
                      width: 28,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(buyWith == 'coins' ? 'assets/images/Coins.png' : 'assets/images/GoldBars.png')
                          )
                      ),
                    ),
                    SizedBox(width: 5,),
                    Text('${NumberFormat('#,###').format(price)}', style: TextStyle(fontSize: 18, color: Colors.white),)
                  ],
                ),
                onPressed: () {
                  DBService().buyBars(buyAmount, price, user).then((value) => Navigator.of(context).pop());
                },
              ),
            )
          ],
        )
      ],
    );
  }
}