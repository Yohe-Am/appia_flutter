import 'models/Message.dart';

class AppiaData {
  static List<Message> chatRoom = [
    Message(
      senderUsername: "Will",
      recieverUsername: "Jada",
      date: "12:05 AM",
      text: "Hello",
    ),
    Message(
      senderUsername: "Jada",
      recieverUsername: "Will",
      date: "12:06 AM",
      text: "Hi, who is this?",
    ),
  ];
  static List<Message> messages = [
    Message(
      senderUsername: "Will",
      recieverUsername: "Jada",
      date: "12:05 AM",
      text: "Hello",
    ),
    Message(
      senderUsername: "Jada",
      recieverUsername: "Will",
      date: "12:06 AM",
      text: "Hi, who is this?",
    ),
    Message(
      senderUsername: "Will",
      recieverUsername: "Jada",
      date: "12:07 AM",
      text: "Oh sorry, do I have the wrong number?",
    ),
    Message(
      senderUsername: "Jada",
      recieverUsername: "Will",
      date: "12:07 AM",
      text: "Well, who are you looking for?",
    ),
    Message(
      senderUsername: "Will",
      recieverUsername: "Jada",
      date: "12:08 AM",
      text: "Oh sorry, I do have the wrong number. Have a nice day.",
    ),
    Message(
      senderUsername: "Jada",
      recieverUsername: "Will",
      date: "12:08 AM",
      text: "Okay",
    ),
  ];
}
