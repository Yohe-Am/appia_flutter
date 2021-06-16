import 'package:appia/blocs/p2p/p2p.dart';
import 'package:appia/blocs/room/room_bloc.dart';
import 'package:appia/blocs/screens/room.dart';
import 'package:appia/blocs/screens/userDetail.dart';
import 'package:appia/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:namester/namester.dart';

import 'screens.dart';
import 'userDetail.dart';

Route generateRoute(RouteSettings settings) {
  if (settings.name == HomeScreen.routeName)
    return MaterialPageRoute(builder: (context) => HomeScreen());
  else if (settings.name == SetupScreen.routeName)
    return MaterialPageRoute(builder: (context) => SetupScreen());
  else if (settings.name == SearchScreen.routeName) {
    return MaterialPageRoute(builder: (context) => SearchScreen());
  } else if (settings.name == UserDetailScreen.routeName) {
    final entry = settings.arguments as UserEntry;
    return MaterialPageRoute(
      builder: (context) => BlocProvider(
        create: (context) => UserDetailScreenBloc(context.read<P2PBloc>()),
        child: UserDetailScreen(entry: entry),
      ),
    );
  } else if (settings.name == RoomScreen.routeName) {
    final room = settings.arguments as Room;
    return MaterialPageRoute(
      builder: (context) => BlocProvider(
        create: (context) => RoomScreenBloc(room, context.read<P2PBloc>())
          ..add(CheckForConnection()),
        child: BlocProvider(
          create: (context) => DemoMessagesCubit(),
          child: RoomScreen(room: room),
        ),
      ),
    );
  }
  return MaterialPageRoute(builder: (context) => LogoScreen());
}
