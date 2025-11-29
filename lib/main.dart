import 'package:flutter/material.dart';
import 'package:flutter_passman_client/controllers/password_controller.dart';
import 'package:flutter_passman_client/models/passentry.dart';
import 'package:flutter_passman_client/ui/_core/app_theme.dart';
import 'package:flutter_passman_client/ui/edit/edit_screen.dart';
import 'package:flutter_passman_client/ui/splash/splash_screen.dart';
import 'package:provider/provider.dart';

import 'ui/home/home_screen.dart';
import 'ui/options/options_screen.dart';
import 'ui/register/register_screen.dart';
import 'ui/search/search_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => PasswordController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Passman',
      theme: AppTheme.appTheme,
      initialRoute: SplashScreen.route,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case SplashScreen.route:
            return MaterialPageRoute(builder: (_) => SplashScreen());
          case HomeScreen.route:
            return MaterialPageRoute(builder: (_) => HomeScreen());
          case OptionsScreen.route:
            return MaterialPageRoute(builder: (_) => OptionsScreen());
          case RegisterScreen.route:
            return MaterialPageRoute(builder: (_) => RegisterScreen());
          case SearchScreen.route:
            return MaterialPageRoute(builder: (_) => SearchScreen());
          case EditScreen.route:
            final entry = settings.arguments as PassEntry;
            return MaterialPageRoute(builder: (_) => EditScreen(entry: entry));
        }
        return null;
      },
    );
  }
}
