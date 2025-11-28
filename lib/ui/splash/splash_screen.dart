import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_passman_client/ui/_core/app_colors.dart';
import 'package:flutter_passman_client/ui/home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const route = "/splash";

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, HomeScreen.route);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 400,
            width: 400,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.backgroundColor, width: 5),
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/images/splashimage.png'),
              ),
            ),
          ),
          Text(
            'Aguarde ...',
            style: TextStyle(
              color: AppColors.mainColor,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          LinearProgressIndicator(
            backgroundColor: Colors.blue[200],
            valueColor: AlwaysStoppedAnimation(AppColors.mainColor),
          ),
        ],
      ),
    );
  }
}
