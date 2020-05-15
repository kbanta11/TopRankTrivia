import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'db_services.dart';
import 'models.dart';
import 'main.dart';


class MessagesDialog extends StatelessWidget {
  User user;

  MessagesDialog(this.user);

  @override
  build(BuildContext context) {
    return user == null ? Center(child: CircularProgressIndicator()) : StreamProvider<List<Message>>.value(
      value: DBService().streamUserMessages(user),
      child: Consumer<List<Message>>(
        builder: (context, messageList, _) {
          messageList.sort((a, b) {
            int order = a.dateSent.compareTo(b.dateSent);
            print('Date 1: ${a.dateSent}/Date 2: ${b.dateSent}/Order: $order');
            return -order;
          });
          return SimpleDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Messages'),
                IconButton(
                  icon: Text('X'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
            children: messageList == null ? [Center(child: Text('You have no messages.'))] : messageList.map((message) {
              print('Message datesent: ${message.dateSent}');
              return Column(
                children: <Widget>[
                  Divider(height: 2.5,),
                  ListTile(
                    title: Text(message.subject),
                    subtitle: Text(Helper().dateTimeToStringShort(message.dateSent)),
                    trailing: IconButton(
                        icon: message.isRead ? Icon(Icons.mail_outline, color: Colors.black26,) : Icon(Icons.mail, color: Colors.green),
                        onPressed: () {
                          DBService().markMessageRead(message, user);
                        }
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return SimpleDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                            contentPadding: EdgeInsets.all(10),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Message'),
                                IconButton(
                                  icon: Text('x'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            ),
                            children: <Widget>[
                              Text('Subject:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                              Text(message.subject, style: TextStyle(fontSize: 16)),
                              SizedBox(height: 8),
                              Text('${message.ladderEndDate != null ? 'Ladder' : 'Game'} Ended:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(message.ladderEndDate != null ? Helper().dateTimeToStringShort(message.ladderEndDate) : Helper().dateTimeToStringShort(message.dateSent), style: TextStyle(fontSize: 16)),
                              SizedBox(height: 8),
                              Text('Message:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(message.message, style: TextStyle(fontSize: 16)),
                            ],
                          );
                        }
                      ).then((_) {
                        DBService().markMessageRead(message, user, value: true);
                      });
                    },
                  ),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}