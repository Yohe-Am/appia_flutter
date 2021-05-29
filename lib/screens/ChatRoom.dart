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
          leading: IconButton(
            icon: Icon(Icons.chevron_left_outlined),
            onPressed: () {},
          ),
          title: Text("Will"),
          actions: [
            PopupMenuButton<int>(
                onSelected: (item) => onSelected(context, item),
                itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 0,
                        child: Text('Settings'),
                      ),
                      PopupMenuItem(
                        value: 1,
                        child: Text('Block'),
                      ),
                    ]),
          ],
        ),
        body: Container(
          height: MediaQuery.of(context).size.height * 0.85,
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
                MessageUI(message: AppiaData.messages[4]),
                MessageUI(message: AppiaData.messages[5]),
                MessageUI(message: AppiaData.messages[4]),
                MessageUI(message: AppiaData.messages[5]),
                MessageUI(message: AppiaData.messages[4]),
                MessageUI(message: AppiaData.messages[5]),
                MessageUI(message: AppiaData.messages[4]),
                MessageUI(message: AppiaData.messages[5]),
                MessageUI(message: AppiaData.messages[4]),
                MessageUI(message: AppiaData.messages[5]),
              ],
            ),
          ),
        ),
        bottomSheet: Container(
          child: Row(
            children: [
              Expanded(
                flex: 8,
                child: TextField(
                  decoration: InputDecoration(hintText: 'Send Message'),
                ),
              ),
              IconButton(icon: Icon(Icons.send), onPressed: sendMessage())
            ],
          ),
          height: 50,
        ),
      ),
    );
  }

  onSelected(BuildContext context, int item) {}

  sendMessage() {}
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
          // Text(message.senderUsername),
          Container(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width * 0.45,
              maxWidth: MediaQuery.of(context).size.width * 0.67,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.all(
                Radius.circular(MediaQuery.of(context).size.width * 0.05),
              ),
              color: Colors.blue.shade100,
            ),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Column(
              children: [
                Row(
                    mainAxisAlignment: message.senderUsername != currentUser
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.end,
                    children: [
                      Flexible(child: Text(message.text)),
                    ]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      message.date,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
