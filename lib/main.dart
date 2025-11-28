import 'package:flutter/material.dart';
import 'package:flutter_passman_client/controllers/password_controller.dart';
import 'package:flutter_passman_client/ui/_core/app_theme.dart';
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
      routes: {
        SplashScreen.route: (context) => SplashScreen(),
        HomeScreen.route: (context) => HomeScreen(),
        OptionsScreen.route: (context) => OptionsScreen(),
        RegisterScreen.route: (context) => RegisterScreen(),
        SearchScreen.route: (context) => SearchScreen(),
      },
    );
  }
}
