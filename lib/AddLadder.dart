import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:trivia_game/LadderPage.dart';
import 'db_services.dart';
import 'main.dart';
import 'models.dart';

class AddLadderDialog extends StatelessWidget {

  @override
  build(BuildContext context) {
    User currentUser = Provider.of<User>(context);
    return ChangeNotifierProvider<AddLadderFormProvider>(
      create: (context) => AddLadderFormProvider(),
      child: Consumer<AddLadderFormProvider>(
        builder: (context, form, _) {
          List<int> feeListCoins = <int>[50, 100, 200, 250, 300, 400, 500, 600, 700, 800, 900, 1000, 1500, 2000, 2500, 3000, 5000, 10000, 25000, 50000, 75000, 100000, 150000, 250000];
          List<int> feeListBars = <int>[1,2,3,4,5,6,7,8,9,10];
          return SimpleDialog(
            title: Center(child: Text('Create A Ladder'),),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
            children: <Widget>[
              SingleChildScrollView(
                padding:  EdgeInsets.fromLTRB(15, 10, 15, 10),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  //height: MediaQuery.of(context).size.height,
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text('Title:'),
                          SizedBox(width: 5,),
                          Expanded(child: TextField(decoration: InputDecoration(hintText: 'Enter Title', errorText: form.titleError ?? '', errorStyle: TextStyle(color: Colors.redAccent)), onChanged: (value) {
                            form.updateTitle(value);
                          },)),
                        ],
                      ),
                      Text('Prize'),
                      TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: 2,
                        onChanged: (value) {
                          form.updatePrize(value);
                        },
                      ),
                      Row(
                        children: <Widget>[
                          Text('Start: '),
                          SizedBox(width: 5,),
                          Expanded(
                            child: DateTimeField(
                              decoration: InputDecoration(errorText: form.startDateError ?? '', errorStyle: TextStyle(color: Colors.redAccent)),
                              format: DateFormat('MMMM d, y h:mm a'),
                              onShowPicker: (context, currentValue) async {
                                DateTime date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now().subtract(Duration(days: 1)),
                                    lastDate: DateTime.now().add(Duration(days: 540)));
                                if(date != null) {
                                  TimeOfDay time = await showTimePicker(context: context,
                                      initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()));
                                  return DateTimeField.combine(date, time);
                                }
                                return currentValue;
                              },
                              onChanged: (value) {
                                form.updateStartDate(value);
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text('End: '),
                          SizedBox(width: 5,),
                          Expanded(
                            child: DateTimeField(
                              decoration: InputDecoration(errorText: form.endDateError ?? '', errorStyle: TextStyle(color: Colors.redAccent)),
                              format: DateFormat('MMMM d, y h:mm a'),
                              onShowPicker: (context, currentValue) async {
                                DateTime date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now().subtract(Duration(days: 1)),
                                    lastDate: DateTime.now().add(Duration(days: 540)));
                                if(date != null) {
                                  TimeOfDay time = await showTimePicker(context: context,
                                      initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()));
                                  return DateTimeField.combine(date, time);
                                }
                                return currentValue;
                              },
                              onChanged: (value) {
                                form.updateEndDate(value);
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text('Coins'),
                          Radio(
                            groupValue: form.type ?? '',
                            value: 'coins',
                            onChanged: (value) {
                              form.updateType(value);
                            },
                          ),
                          SizedBox(width: 25,),
                          Text('Bars'),
                          Radio(
                            groupValue: form.type ?? '',
                            value: 'bars',
                            onChanged: (value) {
                              form.updateType(value);
                            },
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Entry Fee:'),
                          SizedBox(width: 5,),
                          Container(
                            child: form.type == 'coins' ? DropdownButton(
                              value: form.entryFee ?? 100,
                              icon: Icon(Icons.arrow_drop_down),
                              items: feeListCoins.map((fee) => DropdownMenuItem(
                                value: fee,
                                child: Text('$fee'),
                              )).toList(),
                              onChanged: (value) {
                                form.updateEntryFee(value);
                              },
                            ) : DropdownButton(
                              value: form.entryFee ?? 100,
                              icon: Icon(Icons.arrow_drop_down),
                              items: feeListBars.map((fee) => DropdownMenuItem(
                                value: fee,
                                child: Text('$fee'),
                              )).toList(),
                              onChanged: (value) {
                                form.updateEntryFee(value);
                              },
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Number of Lives:'),
                          SizedBox(width: 5,),
                          Container(
                            child: DropdownButton(
                              value: form.numLives ?? 3,
                              icon: Icon(Icons.arrow_drop_down),
                              items: <int>[-1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,18,20,25,30].map((lives) => DropdownMenuItem(
                                value: lives,
                                child: Text('${lives < 0 ? 'Unlimited' : lives}'),
                              )).toList(),
                              onChanged: (value) {
                                form.updateNumLives(value);
                              },
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Respawn Time:'),
                          SizedBox(width: 5,),
                          Container(
                            child: DropdownButton(
                              value: form.respawnMinutes ?? 30,
                              icon: Icon(Icons.arrow_drop_down),
                              items: <int>[0, 2, 5, 10, 15, 20, 25, 30, 45, 60, 90, 120, 180, 240].map((time) {
                                Duration timeDur = Duration(minutes: time);
                                String timeString;

                                if(timeDur.inMinutes.remainder(60) == 0) {
                                  if(timeDur.inHours == 1)
                                    timeString = '${timeDur.inHours} hour';
                                  else
                                    timeString = '${timeDur.inHours} hours';
                                } else {
                                  timeString = '${timeDur.inMinutes} minutes';
                                }
                                if(timeDur.inMinutes == 0)
                                  timeString = 'No wait';

                                return DropdownMenuItem(
                                  value: time,
                                  child: Text(timeString),
                                );
                              }).toList(),
                              onChanged: (value) {
                                form.updateRespawn(value);
                              },
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          OutlineButton(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          FlatButton(
                            child: Text('Create!', style: TextStyle(color: Colors.white),),
                            color: Colors.cyan,
                            onPressed: () async {
                              form.createLadder(currentUser.userId).then((ladder) {
                                if(ladder != null)
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => LadderPage(ladder)));
                              });
                            },
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class AddLadderFormProvider extends ChangeNotifier {
  String title;
  String titleError;
  String prize;
  DateTime startDate;
  String startDateError;
  DateTime endDate;
  String endDateError;
  int entryFee = 50;
  int numLives = 9;
  int respawnMinutes = 30;
  String type = 'coins';

  void updateTitle(String newTitle) {
    title = newTitle;
  }

  void updatePrize(String newPrize) {
    prize = newPrize;
  }

  void updateStartDate(DateTime date) {
    startDate = date;
  }

  void updateEndDate(DateTime date) {
    endDate = date;
  }

  void updateType(String value) {
    type = value;
    if(value == 'coins') {
      entryFee = 250;
    } else {
      entryFee = 1;
    }
    notifyListeners();
  }

  void updateEntryFee(int fee) {
    entryFee = fee;
    notifyListeners();
  }

  void updateNumLives(int lives) {
    numLives = lives;
    notifyListeners();
  }

  void updateRespawn(int minutes) {
    respawnMinutes = minutes;
    notifyListeners();
  }

  Future<Ladder> createLadder(String creatingUserId) async {
    if(title == null || title.length == 0) {
      titleError = 'Please enter a title!';
    } else {
      titleError = null;
    }

    if(startDate == null) {
      startDateError = 'You must choose a start date and time!';
    } else if(startDate.isBefore(DateTime.now())) {
      startDateError = 'Start Date must not be in the past!';
    } else {
      startDateError = null;
    }

    if(endDate == null) {
      endDateError = 'You must choose an end date!';
    } else if(endDate.isBefore(startDate)) {
      endDateError = 'The ladder must end after it starts!';
    } else if(endDate.difference(startDate).inMinutes < 30) {
      print('Minutes: ${startDate.difference(endDate).inMinutes}');
      endDateError = 'Ladders must be at least 30 minutes long!';
    } else {
      endDateError = null;
    }

    if(titleError == null && startDateError == null && endDateError == null) {
      notifyListeners();
      print('creating ladder');
      return await DBService().createNewLadder(createdBy: creatingUserId, title: title, prize: prize, startDate: startDate, endDate: endDate, type: type, entryFee: entryFee, numLives: numLives, respawnTime: respawnMinutes);
    }
    notifyListeners();
    return null;
  }
}