import 'package:flutter/material.dart';


class HowToDialog extends StatelessWidget {
  @override
  build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text('How To Play'),
          IconButton(
            icon: Text('X'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      children: <Widget>[
        Text('Ladder Play', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), //Can make Row of buttons when more game modes added
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[
              Text('Overview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 10),
              Text('Ladders are Top Trivia’s primary contest. Ladders are like tournaments: you pay an entry of coins or gold bars with the goal of being the Top ranked player when the ladder ends. Ladders will typically run for one day or one week. While the ladder is running, players can play rounds of trivia to score points and climb up the ladder leaderboard. The more questions you answer correctly in a row, the higher your score will be.\n\nWhen you answer a question incorrectly, it will end your round, stop your streak and cost you a life (some ladders have unlimited lives, however).  After each round, there may be a wait time before you are able to play again on that ladder.'),
              SizedBox(height: 10),
              Text('Playing the Game', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 10),
              Text('Playing a round is simple: Simply answer questions correctly. At the start of each round, your streak will start over. For each question that you answer correctly, your score for that question will be added to your total ladder score. Each subsequent question answered correctly will be worth more points than the previous questions (scoring outlined below), with multipliers for making it to different streak levels.\n\nQuestions will be True/False questions or Multiple Choice questions with 4 answer choices (1 correct and 3 incorrect options).  Questions will come from a variety of categories including Art, Entertainment, Sports, History, Geography and General Knowledge.  Players will have 10 seconds to answer each question.'),
              SizedBox(height: 10),
              Text('Power Ups', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 10),
              Text('During each round, players are able to get a little helping hand in the form of Power Ups. You can use each Power Up once per round:'),
              Text('    1.  50/50 - The 50/50 power up will remove two incorrect answers, leaving you with two options: one correct and one incorrect. You’ve got a 50/50 chance even with a random guess!'),
              Text('    2.  Community Stats - The Community Stats power up will show you the number of times other players have chosen each of the possible answers. Do you trust your fellow players’ trivia skill?'),
              Text('    3.  Re-Roll - Have a question that’s just nowhere close to your wheelhouse?  Try a Re-Roll to get a new question!'),
              SizedBox(height: 10),
              Text('Scoring', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 10),
              Text('Scoring is based on the number of questions you get right and how far into a “streak” of correct answers you are when you answer that question.  Each question is worth the value of the streak (if you are answering the 4th question, your streak is 4) multiplied by the Multiplier.\n\nMultipliers are also determined by how long your streak is. The longer the streak, the higher the multiplier (you can see how long streaks is the key to victory)! Every 5 questions, there is a “Bonus Multiplier” increasing your score when you cross each 5 question tier. Multiplier tiers are as follows: '),
              SizedBox(height: 6),
              Center(
                child: scoreTable,
              ),
              SizedBox(height: 10),
              Text('End of Ladder', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 10),
              Text('When the ladder ends, players will no longer be able to play new rounds or improve their score.  The final rankings will lock in and players will be paid out based on their ranking.  Coin ladders will typically payout coins a decreasing scale of gold coins to the top 25% of players based on the total prize pool of that ladder (determined by multiplying the entry fee by the total number of players).  For ladders with less than 100 players, a smaller number of the top ranked players may be considering winners and receive a payout.\n\nFor Gold Bar-based ladders, there will typically be a predetermined prize.  Prizes and payouts will be laid out in the ladder details for each ladder. Bar ladders may only have a prize for the top player or the top 10 players, regardless of the number of entrants.\n\nCoin-based ladders will be paid out 15 minutes after the hour on which the ladder ends. For Bar ladder prizes, we will contact the winners within the business day after that ladder ends.')
            ],
          ),
        ),
      ],
    );
  }
}

Table scoreTable = Table(
  border: TableBorder.all(color: Colors.black,),
  children: <TableRow>[
    TableRow(
        children: [
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('Question #'),
            ),
          ),
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('Multiplier'),
            ),
          ),
        ],
    ),
    TableRow(
        children: [
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('1-4'),
            ),
          ),
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('1x'),
            ),
          ),
        ]
    ),
    TableRow(
        children: [
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('5'),
            ),
          ),
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('5x'),
            ),
          ),
        ]
    ),
    TableRow(
        children: [
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('6-9'),
            ),
          ),
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('2x'),
            ),
          ),
        ]
    ),
    TableRow(
        children: [
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('10'),
            ),
          ),
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('10x'),
            ),
          ),
        ]
    ),
    TableRow(
        children: [
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('11-14'),
            ),
          ),
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('4x'),
            ),
          ),
        ]
    ),
    TableRow(
        children: [
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('15'),
            ),
          ),
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('15x'),
            ),
          ),
        ]
    ),
    TableRow(
        children: [
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('16-19'),
            ),
          ),
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('8x'),
            ),
          ),
        ]
    ),
    TableRow(
        children: [
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('20'),
            ),
          ),
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('20x'),
            ),
          ),
        ]
    ),
    TableRow(
        children: [
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('21-24'),
            ),
          ),
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('12x'),
            ),
          ),
        ]
    ),
    TableRow(
        children: [
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('25'),
            ),
          ),
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('25x'),
            ),
          ),
        ]
    ),
    TableRow(
        children: [
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('26-29'),
            ),
          ),
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('16x'),
            ),
          ),
        ]
    ),
    TableRow(
        children: [
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('30'),
            ),
          ),
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('30x'),
            ),
          ),
        ]
    ),
    TableRow(
        children: [
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('31-34'),
            ),
          ),
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('20x'),
            ),
          ),
        ]
    ),
    TableRow(
        children: [
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('35'),
            ),
          ),
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('35x'),
            ),
          ),
        ]
    ),
    TableRow(
        children: [
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('36-39'),
            ),
          ),
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('24x'),
            ),
          ),
        ]
    ),
    TableRow(
        children: [
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('40'),
            ),
          ),
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('40x'),
            ),
          ),
        ]
    ),
    TableRow(
        children: [
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('41-44'),
            ),
          ),
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('28x'),
            ),
          ),
        ]
    ),
    TableRow(
        children: [
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('45'),
            ),
          ),
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('45x'),
            ),
          ),
        ]
    ),
    TableRow(
        children: [
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('46-49'),
            ),
          ),
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('32x'),
            ),
          ),
        ]
    ),
    TableRow(
        children: [
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('50'),
            ),
          ),
          TableCell(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 8, 0),
              child: Text('100x'),
            ),
          ),
        ]
    ),
  ],
);