import 'dart:convert';

import 'package:appia/blocs/p2p/connection_bloc.dart' as conn_bloc;
import 'package:appia/blocs/screens/room.dart';
import 'package:appia/p2p/transports/transports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:appia/models/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Messages {
  final List<String> messages;

  Messages(this.messages);
}

class DemoMessagesCubit extends Cubit<Messages> {
  DemoMessagesCubit() : super(Messages([]));
  void addMessage(String s) {
    print("message added $s");
    final state = this.state;
    state.messages.add(s);
    emit(Messages(state.messages));
  }
}

class RoomScreen extends StatefulWidget {
  static const String routeName = "room";
  final Room room;

  const RoomScreen({Key? key, required this.room}) : super(key: key);

  @override
  _RoomScreenState createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final _msgformKey = GlobalKey<FormState>();

  String _event = "echo";
  String _message = "hello appia";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocConsumer<RoomScreenBloc, RoomScreenState>(
          listener: (context, state) {
            if (state is HasConnection) {
              final conn = state.conn.eventedConnection;
              final cubit = context.read<DemoMessagesCubit>();

              conn.stream.listen((msg) {
                cubit.addMessage("incoming " + jsonEncode(msg.toJson()));
              }, onError: (e) {
                cubit.addMessage("error from evented connection: $e");
              }, onDone: () {
                cubit.addMessage("connection finished: ${conn.closeReason}");
              });
              cubit.addMessage(
                  "connected to peer at: ${conn.peerAddress.toString()}");
            }
          },
          builder: (context, state) => state is HasConnection
              ? BlocBuilder<conn_bloc.ConnectionBloc,
                  conn_bloc.ConnectionState>(
                  bloc: state.conn,
                  builder: (context, state) =>
                      state == conn_bloc.ConnectionState.Connected
                          ? Text("Connected")
                          : state == conn_bloc.ConnectionState.Connected
                              ? const Text("Connecting")
                              : const Text("Not Connected"),
                )
              : Row(
                  children: <Widget>[
                    const Text("Not Connected"),
                    ElevatedButton(
                        onPressed: () {
                          context
                              .read<RoomScreenBloc>()
                              .add(CheckForConnection());
                        },
                        child: const Text("Check")),
                  ],
                ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Messages:',
          ),
          Expanded(
            child: BlocBuilder<DemoMessagesCubit, Messages>(
              builder: (context, state) => ListView.builder(
                itemCount: state.messages.length,
                itemBuilder: (context, index) => Text(state.messages[index]),
              ),
            ),
          ),
          Form(
            key: this._msgformKey,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: this._event,
                        onSaved: (value) {
                          if (value != null)
                            setState(() {
                              this._event = value;
                            });
                        },
                        validator: (msg) {
                          if (msg == null || msg.isEmpty) {
                            return "Event field is empty.";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: this._message,
                        onSaved: (value) {
                          if (value != null)
                            setState(() {
                              this._message = value;
                            });
                        },
                        validator: (msg) {
                          if (msg == null || msg.isEmpty) {
                            return "Message field is empty.";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                BlocBuilder<RoomScreenBloc, RoomScreenState>(
                  builder: (context, roomState) => roomState is HasConnection
                      ? BlocBuilder<conn_bloc.ConnectionBloc,
                          conn_bloc.ConnectionState>(
                          bloc: roomState.conn,
                          builder: (context, state) => ElevatedButton(
                            onPressed: state ==
                                    conn_bloc.ConnectionState.Connected
                                ? () {
                                    final form = this._msgformKey.currentState;
                                    final msg = EventMessage(
                                        this._event, this._message);
                                    if (form != null && form.validate()) {
                                      form.save();
                                      roomState.conn.eventedConnection
                                          .emitEvent(msg)
                                          .then(
                                        (v) => context
                                            .read<DemoMessagesCubit>()
                                            .addMessage("outgoing: " +
                                                jsonEncode(msg.toJson())),
                                        onError: (e) {
                                          context
                                              .read<DemoMessagesCubit>()
                                              .addMessage(
                                                "error sending message $e",
                                              );
                                        },
                                      );
                                    }
                                  }
                                : null,
                            child: const Text("Send"),
                          ),
                        )
                      : const Text("Not Connected"),
                )
              ],
            ),
          )
        ],
      ),
    );

    /* return MultiBlocProvider(
      providers: [
        BlocProvider<MessageBloc>(
          create: (context) => messageBloc..add(LoadMessages()),
        ),
        BlocProvider<RoomBloc>(create: (context) => roomBloc),
      ],
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
              messageBloc.add(LoadMessages());
              roomBloc.add(AddRoom(room));
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
                  TextMessage message = TextMessage(myController.text,
                      id: 6,
                      authorId: MyApp.currentUser.id,
                      authorUsername: MyApp.currentUser.username,
                      timestamp: DateTime.now());
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
    ); */
  }
}
/* import 'dart:convert';

import 'package:appia/blocs/p2p/connection_bloc.dart' as conn_bloc;
import 'package:appia/blocs/room/room_bloc.dart';
import 'package:appia/blocs/screens/room.dart';
import 'package:appia/p2p/transports/transports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:appia/models/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Messages {
  final List<String> messages;

  Messages(this.messages);
}

class DemoMessagesCubit extends Cubit<Messages> {
  Room room;
  RoomBloc bloc;
  DemoMessagesCubit(this.room, this.bloc) : super(Messages([]));
  void addMessage(RoomEntry r) {
    () async {
      List<RoomEntry> entries = await bloc.repo.getRoomEntries(room.id) ?? [];
      entries.add(r);
      final json = jsonEncode(r.toJson());
      print("message added $json");
      final state = this.state;
      state.messages.add(json);
      emit(Messages(state.messages));
    }();
  }
}

class RoomScreen extends StatefulWidget {
  static const String routeName = "room";
  final Room room;

  const RoomScreen({Key? key, required this.room}) : super(key: key);

  @override
  _RoomScreenState createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final _msgformKey = GlobalKey<FormState>();

  String _event = "echo";
  String _message = "hello appia";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<RoomScreenBloc, RoomScreenState>(
          builder: (context, state) => state is HasConnection
              ? BlocBuilder<conn_bloc.ConnectionBloc,
                  conn_bloc.ConnectionState>(
                  bloc: state.conn,
                  builder: (context, state) =>
                      state == conn_bloc.ConnectionState.Connected
                          ? Text("Connected")
                          : state == conn_bloc.ConnectionState.Connected
                              ? const Text("Connecting")
                              : const Text("Not Connected"),
                )
              : Row(
                  children: <Widget>[
                    const Text("Not Connected"),
                    ElevatedButton(
                        onPressed: () {
                          context
                              .read<RoomScreenBloc>()
                              .add(CheckForConnection());
                        },
                        child: const Text("Check")),
                  ],
                ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Messages:',
          ),
          Expanded(
            child: BlocBuilder<DemoMessagesCubit, Messages>(
              builder: (context, state) => ListView.builder(
                itemCount: state.messages.length,
                itemBuilder: (context, index) => Text(state.messages[index]),
              ),
            ),
          ),
          Form(
            key: this._msgformKey,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: this._event,
                        onSaved: (value) {
                          if (value != null)
                            setState(() {
                              this._event = value;
                            });
                        },
                        validator: (msg) {
                          if (msg == null || msg.isEmpty) {
                            return "Event field is empty.";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: this._message,
                        onSaved: (value) {
                          if (value != null)
                            setState(() {
                              this._message = value;
                            });
                        },
                        validator: (msg) {
                          if (msg == null || msg.isEmpty) {
                            return "Message field is empty.";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                BlocBuilder<RoomScreenBloc, RoomScreenState>(
                  builder: (context, roomState) => roomState is HasConnection
                      ? BlocBuilder<conn_bloc.ConnectionBloc,
                          conn_bloc.ConnectionState>(
                          bloc: roomState.conn,
                          builder: (context, state) => ElevatedButton(
                            onPressed: state ==
                                    conn_bloc.ConnectionState.Connected
                                ? () {
                                    final form = this._msgformKey.currentState;
                                    final msg = EventMessage(
                                        this._event, this._message);
                                    if (form != null && form.validate()) {
                                      form.save();
                                      roomState.conn.eventedConnection
                                          .emitEvent(msg)
                                          .then(
                                        (v) => context
                                            .read<DemoMessagesCubit>()
                                            .addMessage(TextMessage(this, id: id, authorId: authorId, authorUsername: authorUsername, timestamp: timestamp)),
                                        onError: (e) {
                                          context
                                              .read<DemoMessagesCubit>()
                                              .addMessage(
                                                "error sending message $e",
                                              );
                                        },
                                      );
                                    }
                                  }
                                : null,
                            child: const Text("Send"),
                          ),
                        )
                      : const Text("Not Connected"),
                )
              ],
            ),
          )
        ],
      ),
    );

    /* return MultiBlocProvider(
      providers: [
        BlocProvider<MessageBloc>(
          create: (context) => messageBloc..add(LoadMessages()),
        ),
        BlocProvider<RoomBloc>(create: (context) => roomBloc),
      ],
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
              messageBloc.add(LoadMessages());
              roomBloc.add(AddRoom(room));
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
                  TextMessage message = TextMessage(myController.text,
                      id: 6,
                      authorId: MyApp.currentUser.id,
                      authorUsername: MyApp.currentUser.username,
                      timestamp: DateTime.now());
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
    ); */
  }
}
 */