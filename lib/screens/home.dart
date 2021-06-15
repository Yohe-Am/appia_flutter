import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appia/blocs/room/room_bloc.dart';

import 'search.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "home";
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // FIXME: ??
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Appia"),
        // TODO: display for listener status
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(SearchScreen.routeName);
            },
            icon: Icon(Icons.search),
          ),
          PopupMenuButton<int>(
              onSelected: (item) => (context, item) {},
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
      body: BlocBuilder<RoomBloc, RoomState>(
        builder: (_, state) {
          if (state is RoomsLoadSuccess) {
            final chats = state.rooms;
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(20),
              child: ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, idx) => ListTile(
                  title: Text(chats[idx].users.toString()),
                ),
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
/* 
class UnseenText extends StatelessWidget {
  final Room room;
  UnseenText({required this.room});

  @override
  Widget build(BuildContext context) {
    var text = room.entries[0];
    //how do you cast in golang
    TextMessage lastMessage = text as TextMessage;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(ChatRoom.routeName, arguments: room);
      },
      child: Container(
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
                child: Center(
                    child: Text("${lastMessage.authorUsername.toUpperCase()}")),
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
                          Text("${lastMessage.authorUsername}"),
                          Text("${lastMessage.text}"),
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
                          Text("${lastMessage.timestamp.toString()}",
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
      ),
    );
  }
}
 */