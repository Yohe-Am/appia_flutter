import 'package:appia/AppiaData.dart';
import 'package:appia/blocs/blocs.dart';
import 'package:appia/models/Message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

String currentUser = "Jada";

class ChatRoom extends StatelessWidget {
  static const routeName = 'ChatRoom';
  final myController = TextEditingController();
  final messageBloc = MessageBloc();
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => messageBloc..add(LoadMessages()),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.chevron_left_outlined),
            onPressed: () {
              Navigator.pop(context);
            },
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
        body: BlocBuilder<MessageBloc, MessageState>(
          builder: (_, state) {
            if (state is MessageSentSuccess) {
              // TODO: Implement event to add the chat to list of chats if it is sending to a new chat
              messageBloc.add(LoadMessages());
            }
            if (state is MessageSentFailure) {
              return Text('Could not load messages');
            }
            if (state is MessagesLoadSuccess) {
              final messages = state.messages;

              return Container(
                height: MediaQuery.of(context).size.height * 0.85,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, idx) =>
                      MessageUI(message: messages[idx]),
                ),
              );
            }
            print(state);
            return Center(child: CircularProgressIndicator());
          },
        ),
        bottomSheet: Container(
          child: Row(
            children: [
              Expanded(
                flex: 8,
                child: TextField(
                  decoration: InputDecoration(hintText: 'Send Message'),
                  controller: myController,
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  Message message = Message(
                      recieverUsername: "Will",
                      senderUsername: currentUser,
                      text: myController.text,
                      date: "12:03AM");
                  MessageEvent event = SendMessage(message);
                  messageBloc.add(event);
                  print(message);
                },
              ),
            ],
          ),
          height: 50,
        ),
      ),
    );
  }

  onSelected(BuildContext context, int item) {}
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
