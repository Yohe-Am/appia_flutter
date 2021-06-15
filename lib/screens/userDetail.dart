import 'package:appia/blocs/p2p/p2p.dart';
import 'package:appia/blocs/screens/userDetail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:appia/blocs/session.dart';
import 'package:namester/namester.dart';

import 'setup.dart';
import 'home.dart';

class UserDetailScreen extends StatefulWidget {
  static const String routeName = "connect";
  final UserEntry entry;

  const UserDetailScreen({Key? key, required this.entry}) : super(key: key);
  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Text(widget.entry.username),
          Text(widget.entry.id),
          Text(widget.entry.address.toJson()),
          BlocBuilder<P2PBloc, P2PBlocState>(
            builder: (context, connectionsState) => connectionsState.connections
                    .containsKey(widget.entry.id)
                ? const Text("Connected")
                : BlocBuilder<UserDetailScreenBloc, UserDetailScreenState>(
                    builder: (context, screenState) => Column(
                      children: <Widget>[
                        screenState is ConnectingError
                            ? Text(
                                "Connection error: ${screenState.error.toString()}")
                            : screenState is Connecting
                                ? CircularProgressIndicator()
                                : TextButton(
                                    onPressed: () {
                                      context
                                          .read<UserDetailScreenBloc>()
                                          .add(ConnectToId(widget.entry.id));
                                    },
                                    child: const Text("Connect"))
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
