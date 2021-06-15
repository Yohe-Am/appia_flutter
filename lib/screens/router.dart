import 'package:flutter/material.dart';

import 'home.dart';
import 'logo.dart';
import 'setup.dart';

Route generateRoute(RouteSettings settings) {
  if (settings.name == HomeScreen.routeName)
    return MaterialPageRoute(builder: (context) => HomeScreen());
  else if (settings.name == SetupScreen.routeName)
    return MaterialPageRoute(builder: (context) => SetupScreen());
  return MaterialPageRoute(builder: (context) => LogoScreen());
}
