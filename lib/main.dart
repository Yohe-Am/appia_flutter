import 'dart:io';

import 'package:appia/p2p/transports/transports.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/p2p/p2p.dart';
import 'p2p/p2p.dart';

void main() {
  // use this async iife to set up a dumb echo server on the local machine
  // for testing
  () async {
    try {
      var transport = new WsTransport();
      var listener = await transport.listen(
        WsListeningAddress(
          InternetAddress.tryParse("127.0.0.1")!,
          8088,
        ),
      );
      listener.incomingConnections
          .map((conn) => new EventedConnection(
                conn,
                onMessage: (_, msg) {
                  print("got message ${msg.toJson()}");
                },
              ))
          .forEach((conn) => conn.listen(
                "echo",
                (connection, data) =>
                    connection.emit(EventMessage("echo", data)),
              ));
    } catch (err) {
      print("err seting up dumb server: $err");
    }
  }();
  runApp(MyApp());
}

/// Namester that always returns the same peerAddress
class DumbNamester extends AbstractNamester {
  final PeerAddress universalAddress;

  DumbNamester(this.universalAddress);
  @override
  Future<PeerAddress?> getAddress(AppiaId id) async {
    return this.universalAddress;
  }

  @override
  Future<void> updateMyAddress(AppiaId id, PeerAddress address) async {}
}

enum DemoState { Connected, Connecting, NotConnected }

/// Cubit for controlling the demo connection
class DemoConnectionCubit extends Cubit<DemoState> {
  final AbstractTransport tport;
  ConnectionBloc? connBloc;
  DemoConnectionCubit()
      : tport = WsTransport(),
        super(DemoState.NotConnected);

  void connect(WsPeerAddress addr) {
    this.tport.dial(addr).then(
      (conn) {
        this.connBloc = ConnectionBloc(conn);
        emit(DemoState.Connected);
      },
      onError: (error, stackTrace) {
        print(
            "err dialing to address (${addr.toString()}): $error\n$stackTrace");
        emit(DemoState.NotConnected);
      },
    );
  }
}

class Messages {
  final List<String> messages;

  Messages(this.messages);
}

// i hate it
// something's broken how something's set up
// hmm
// I guess this fellow is enterprising as a little repository
class DemoMessagesCubit extends Cubit<Messages> {
  final DemoConnectionCubit connCubit;

  DemoMessagesCubit(this.connCubit) : super(Messages([])) {
    this.connCubit.stream.listen((event) {
      if (event == DemoState.Connected) {
        connCubit.connBloc!.eventedConnection.onMessage = (_, msg) {
          this._addMessage("incoming " + msg.toJson());
        };
      }
    });
  }
  void sendMessage(EventMessage<dynamic> msg) {
    this
        .connCubit
        .connBloc!
        .eventedConnection
        .emit(msg)
        .then((v) => this._addMessage("outgoing: " + msg.toJson()));
  }

  void _addMessage(String s) {
    final state = this.state;
    state.messages.add(s);
    emit(Messages(state.messages));
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      // provide repositorys first
      MultiRepositoryProvider(
          providers: [
            RepositoryProvider(
              create: (context) {
                final transport = new WsTransport();
                final bloc = new P2PBloc(
                  P2PNode(
                    DumbNamester(
                      WsPeerAddress(Uri.parse("ws://127.0.0.1:8080")),
                    ),
                    tports: [WsTransport()],
                  ),
                );
                transport
                    .listen(WsListeningAddress(
                      InternetAddress.tryParse("127.0.0.1")!,
                      8080,
                    ))
                    .then((listener) => bloc.node.addListener(listener))
                    .onError(
                  (error, stackTrace) {
                    print(
                        "error establishing node listener: $error\n$stackTrace");
                  },
                );
                return bloc;
              },
            ),
          ],
          // then come the blocs
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => DemoConnectionCubit()),
              BlocProvider(
                create: (context) =>
                    DemoMessagesCubit(context.read<DemoConnectionCubit>()),
              )
            ],
            child: MaterialApp(
              title: 'Appia Demo',
              theme: ThemeData(
                primarySwatch: Colors.pink,
              ),
              home: MyHomePage(title: 'Appia Demo'),
            ),
          ));
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _connectFormKey = GlobalKey<FormState>();
  final _msgformKey = GlobalKey<FormState>();

  String _event = "echo";
  String _message = "hello appia";

  String _peerHost = "127.0.0.1";
  int _peerPort = 8088;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<DemoConnectionCubit, DemoState>(
          builder: (context, state) => state == DemoState.Connected
              ? Text("Connected")
              : state == DemoState.Connecting
                  ? Text("Connecting")
                  : Text("Not Connected"),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Form(
            key: this._connectFormKey,
            child: BlocBuilder<DemoConnectionCubit, DemoState>(
              builder: (context, state) => Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      enabled: state == DemoState.NotConnected,
                      initialValue: this._peerHost,
                      onSaved: (value) {
                        if (value != null)
                          setState(() {
                            this._peerHost = value;
                          });
                      },
                      validator: (host) {
                        if (host == null || host.isEmpty) {
                          return "Host field is empty.";
                        }
                        return null;
                      },
                    ),
                  ),
                  Container(
                    width: 75,
                    child: TextFormField(
                      enabled: state == DemoState.NotConnected,
                      initialValue: this._peerPort.toString(),
                      onSaved: (value) {
                        if (value != null)
                          setState(() {
                            this._peerPort = int.parse(value);
                          });
                      },
                      validator: (port) {
                        if (port == null || port.isEmpty) {
                          return "Port field is empty.";
                        }
                        if (int.tryParse(port) == null) {
                          return "Port field is invalid.";
                        }
                        return null;
                      },
                    ),
                  ),
                  state == DemoState.NotConnected
                      ? ElevatedButton(
                          onPressed: () {
                            final form = this._msgformKey.currentState;
                            if (form != null && form.validate()) {
                              form.save();
                              context.read<DemoConnectionCubit>().connect(
                                    WsPeerAddress(
                                      Uri(
                                          scheme: "ws",
                                          host: this._peerHost,
                                          port: this._peerPort),
                                    ),
                                  );
                            }
                          },
                          child: const Text("Connect"),
                        )
                      : state == DemoState.Connected
                          ? ElevatedButton(
                              onPressed: () {
                                // TODO:
                              },
                              child: const Text("Disconnect"),
                            )
                          : ElevatedButton(
                              onPressed: null, child: const Text("Wait")),
                ],
              ),
            ),
          ),
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
                BlocBuilder<DemoConnectionCubit, DemoState>(
                  builder: (context, state) => ElevatedButton(
                    onPressed: state == DemoState.Connected
                        ? () {
                            final form = this._msgformKey.currentState;
                            if (form != null && form.validate()) {
                              form.save();
                              context.read<DemoMessagesCubit>().sendMessage(
                                    EventMessage(this._event, this._message),
                                  );
                            }
                          }
                        : null,
                    child: const Text("Send"),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
