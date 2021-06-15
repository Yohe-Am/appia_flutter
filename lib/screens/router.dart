import 'package:flutter/material.dart';

import 'screens.dart';

Route generateRoute(RouteSettings settings) {
  if (settings.name == HomeScreen.routeName)
    return MaterialPageRoute(builder: (context) => HomeScreen());
  else if (settings.name == SetupScreen.routeName)
    return MaterialPageRoute(builder: (context) => SetupScreen());
  else if (settings.name == Search.routeName) {
    return MaterialPageRoute(builder: (context) => Search());
  }

  return MaterialPageRoute(builder: (context) => LogoScreen());
}
