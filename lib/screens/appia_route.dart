import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:appia/appia.dart';
import '../appia.dart';



class AppiaAppRoute {
  static Route generateRoute(RouteSettings settings) {
    if (settings.name == '/') {
      return MaterialPageRoute(builder: (context) => Search());
    }
    
    if (settings.name == Search.routeName) {
      return MaterialPageRoute(builder: (context) => Search());
    }

    
    if (settings.name == HomePage.routeName) {
      return MaterialPageRoute(
        builder: (context) => HomePage(),
      );
    }

    return MaterialPageRoute(builder: (context) => HomePage());
  }
}
