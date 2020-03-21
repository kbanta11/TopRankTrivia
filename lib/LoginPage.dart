import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:provider/provider.dart';
import 'package:trivia_game/main.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'db_services.dart';

class LoginPage extends StatelessWidget {
  DBService _db = DBService();

  @override
  build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/images/Background.png')
        )
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ChangeNotifierProvider<LoginProvider>(
          create: (context) => LoginProvider(),
          child: Consumer<LoginProvider>(
            builder: (context, loginProvider, _) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/images/LoginPanelbg.png'),
                              fit: BoxFit.fill
                          )
                      ),
                      child: Container(
                        width: 300,
                        height: 250,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: 250,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage('assets/images/google-btn.png'),
                                      fit: BoxFit.fill
                                  )
                              ),
                              child: MaterialButton(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 40),
                                  child: Text('Sign In With Google', style: TextStyle(fontSize: 16, color: Colors.white, fontFamily: 'Sans'), textAlign: TextAlign.left,),
                                ),
                                onPressed: () async {
                                  if(loginProvider.agreeToTerms)
                                    await _db.signInWithGoogle().then((value) => value == 'Success' ? Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage())) : null);
                                },
                              ),
                            ),
                            SizedBox(height: 30.0,),
                            Container(
                              width: 250,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage('assets/images/fb-btn.png'),
                                      fit: BoxFit.fill
                                  )
                              ),
                              child: MaterialButton(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 40),
                                  child: Text('Sign In With Facebook', style: TextStyle(fontSize: 16, color: Colors.white, fontFamily: 'Sans'),),
                                ),
                                onPressed: () async {
                                  if(loginProvider.agreeToTerms)
                                    await _db.facebookLogin().then((value) => value == 'Success' ? Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage())) : null);
                                },
                              ),
                            ),
                            SizedBox(height: 15),
                            Row(
                              children: <Widget>[
                                Checkbox(
                                  value: loginProvider.agreeToTerms,
                                  onChanged: (value) {
                                    loginProvider.updateTerms(value);
                                  },
                                ),
                                Container(
                                  width: 200,
                                  child: RichText(
                                    text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'By signing in or signing, you are agreeing to our ',
                                            style: TextStyle(color: Colors.black)
                                          ),
                                          TextSpan(
                                              text: 'terms and conditions',
                                              style: TextStyle(color: Colors.blue,),
                                              recognizer: TapGestureRecognizer()..onTap = () {launch('https://www.termsfeed.com/terms-conditions/ed08223fe129402a28b6dc197c63853f');}
                                          ),
                                          TextSpan(
                                              text: ' and ',
                                              style: TextStyle(color: Colors.black)
                                          ),
                                          TextSpan(
                                              text: 'privacy policy.',
                                              style: TextStyle(color: Colors.blue,),
                                              recognizer: TapGestureRecognizer()..onTap = () {launch('https://topranktrivia.com/privacy-policy/');}
                                          )
                                        ]
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class LoginProvider extends ChangeNotifier {
  bool agreeToTerms = false;

  void updateTerms(bool val) {
    agreeToTerms = val;
    notifyListeners();
  }
}