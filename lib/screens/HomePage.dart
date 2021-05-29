import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  static const routeName = 'HomePage';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Appia"),
          actions: [
            IconButton(
              onPressed: searchPressed(),
              icon: Icon(Icons.search),
            ),
            PopupMenuButton<int>(
                onSelected: (item) => onSelected(context, item),
                itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 0,
                        child: Text('Settings'),
                      ),
                      PopupMenuItem(
                        value: 1,
                        child: Text('Blocked List'),
                      ),
                      PopupMenuItem(
                        value: 1,
                        child: Text('Log out'),
                      ),
                    ]),
          ],
        ),
        body: Container(
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
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
        )
        // bottomSheet: Container(
        //   color: Colors.red,
        //   height: 100,
        // ),
        );
  }

  onSelected(BuildContext context, int item) {}

  searchPressed() {}
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
            child: Container(
              constraints: BoxConstraints(
                  maxHeight: 50.0,
                  maxWidth: 50.0,
                  minWidth: 50.0,
                  minHeight: 50.0),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Center(child: Text("L")),
            ),
          ),
          Expanded(
            flex: 8,
            child: Container(
              margin: EdgeInsets.only(left: 5),
              decoration: BoxDecoration(
                  border: Border(
                bottom: BorderSide(color: Colors.blueAccent),
              )),
              child: Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Lydia Solomon"),
                        Text("Hey Girl!!!"),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(5),
                          child: Text("68"),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(15),
                              right: Radius.circular(15),
                            ),
                          ),
                        ),
                        Text("12:24",
                            style: DefaultTextStyle.of(context)
                                .style
                                .apply(fontSizeFactor: 0.9)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
