import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:trivia_game/AddLadder.dart';
import 'models.dart';
import 'db_services.dart';
import 'main.dart';

class AdminPage extends StatelessWidget {
  @override
  build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TopMenu(),
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('Admin', style: TextStyle(fontSize: 30),),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            FlatButton(
              color: Colors.cyan,
              child: Text('Add New Ladder'),
              onPressed: () async {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AddLadderDialog();
                    }
                );
              },
            ),
            SizedBox(height: 10),
            FlatButton(
              color: Colors.cyan,
              child: Text('Verify Questions'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return StreamProvider(
                      create: (context) => DBService().streamUnverifiedQuestions(),
                      child: VerifyQuestionDialog(),
                    );
                  }
                );
              },
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(context: context,),
    );
  }
}

class VerifyQuestionDialog extends StatelessWidget {
  @override
  build(BuildContext context) {
    List<Question> unverifiedQuestion = Provider.of<List<Question>>(context);
    unverifiedQuestion = unverifiedQuestion.where((element) => element.isVerified != true).toList();
    Question topQuestion = unverifiedQuestion != null ? unverifiedQuestion.first : null;
    TextEditingController correctAnswerController = TextEditingController(text: '${topQuestion.answers.where((ans) => ans.isCcorrect).first.value}');
    TextEditingController questionController = TextEditingController(text: '${topQuestion.question}');
    TextEditingController answer1;
    TextEditingController answer2;
    TextEditingController answer3;
    return unverifiedQuestion == null ? Container() : SimpleDialog(
      contentPadding: EdgeInsets.all(15),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Text('Verify Questions'),
          Text('${unverifiedQuestion.length}', style: TextStyle(fontSize: 16, fontFamily: 'Sans'),),
        ],
      ),
      children: <Widget>[
        TextField(
          controller: questionController,
          style: TextStyle(fontSize: 16, fontFamily: 'Sans'),
          maxLines: 3,
          onChanged: (val) {
            topQuestion.question = val;
          },
        ),
        SizedBox(height: 10),
        Text('Correct Answer:', style: TextStyle(fontSize: 16, fontFamily: 'Sans'),),
        TextField(
          controller: correctAnswerController,
          style: TextStyle(fontSize: 16, fontFamily: 'Sans'),
          onChanged: (val) {
            topQuestion.answers.where((element) => element.isCcorrect).first.value = val;
          },
        ),
        SizedBox(height: 10),
        Text('Other Options:', style: TextStyle(fontSize: 16, fontFamily: 'Sans'),),
        Column(
          children: topQuestion.answers.where((ans) => !ans.isCcorrect).map((answer) {
            TextEditingController _controller = TextEditingController(text: answer.value);
            if(answer1 == null)
              answer1 = _controller;
            else if(answer2 == null)
              answer2 = _controller;
            else if(answer3 == null)
              answer3 = _controller;
            return TextField(
              controller: _controller,
              style: TextStyle(fontSize: 16, fontFamily: 'Sans'),
              onChanged: (val) {
                answer.value = val;
              },
            );
          }).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            OutlineButton(
              child: Icon(Icons.save),
              onPressed: () {
                DBService().updateQuestion(topQuestion);
              }
            ),
            FlatButton(
              child: Icon(Icons.delete_forever, color: Colors.white,),
              color: Colors.deepOrangeAccent,
              onPressed: () {
                DBService().deleteQuestion(topQuestion);
              }
            ),
            FlatButton(
              color: Colors.cyan,
              child: Text('Verify'),
              onPressed: () async {
                await DBService().verifyQuestion(topQuestion);
              },
            )
          ],
        )
      ],
    );
  }
}