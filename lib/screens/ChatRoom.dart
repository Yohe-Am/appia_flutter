import 'package:appia/AppiaData.dart';
import 'package:appia/models/Message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

String currentUser = "Jada";

class ChatRoom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Appia"),
          actions: [
            IconButton(
              onPressed: null,
              icon: Icon(Icons.search),
            ),
            Text("Contacts"),
            Text("Settings"),
            Text("Blocked List"),
          ],
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                MessageUI(message: AppiaData.messages[0]),
                MessageUI(message: AppiaData.messages[1]),
                MessageUI(message: AppiaData.messages[2]),
                MessageUI(message: AppiaData.messages[3]),
                MessageUI(message: AppiaData.messages[4]),
                MessageUI(message: AppiaData.messages[5]),
              ],
            ),
          ),
        ),
        bottomSheet: Container(
          //text field typing one... row with textfield and send message
          color: Colors.red,
          height: 50,
        ),
      ),
    );
  }
}

class MessageUI extends StatelessWidget {
  Message message;
  MessageUI({required this.message});
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: message.senderUsername != currentUser
          ? Alignment.centerLeft
          : Alignment.centerRight,
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: message.senderUsername != currentUser
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Text(message.senderUsername),
          Container(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width * 0.25,
              maxWidth: MediaQuery.of(context).size.width * 0.67,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.all(
                Radius.circular(MediaQuery.of(context).size.width * 0.1),
              ),
              color: Colors.blue.shade100,
            ),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Column(
              crossAxisAlignment: message.senderUsername != currentUser
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Text(message.text),
                Text(
                  message.date,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
