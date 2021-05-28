import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              UnseenText(),
              UnseenText(),
              UnseenText(),
              UnseenText(),
              UnseenText(),
            ],
          ),
        ),
      ),
      // bottomSheet: Container(
      //   color: Colors.red,
      //   height: 100,
      // ),
    );
  }
}

class UnseenText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.width * 0.2,
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Container(padding: EdgeInsets.all(20), child: Text("L"))),
          Expanded(
            flex: 6,
            child: Column(
              children: [
                Text("Lydia Solomon"),
                Text("Hey Girl!!!"),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Container(
                  child: Text("2"),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                ),
                Text("12:24"),
              ],
            ),
          )
        ],
      ),
    );
  }
}
