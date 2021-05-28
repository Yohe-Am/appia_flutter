class Message {
  String recieverUsername;
  String senderUsername;
  String text;
  String date;

  Message({
    required this.recieverUsername,
    required this.senderUsername,
    required this.date,
    required this.text,
  });

  @override
  String toString() {
    // TODO: implement toString
    return "Message from $senderUsername to $recieverUsername on $date saying $text";
  }
}
