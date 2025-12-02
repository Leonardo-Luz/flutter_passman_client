import 'package:flutter/material.dart';
import 'package:flutter_passman_client/ui/_core/app_colors.dart';
import 'package:flutter_passman_client/ui/home/home_screen.dart';
import 'package:flutter_passman_client/ui/options/options_screen.dart';
import 'package:flutter_passman_client/ui/register/register_screen.dart';
import 'package:flutter_passman_client/ui/search/search_screen.dart';

BottomNavigationBar getBottomBar(BuildContext context, int currentIndex) {
  return BottomNavigationBar(
    currentIndex: currentIndex,
    onTap: (index) {
      if (index == currentIndex) return;

      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, SearchScreen.route);
          break;

        case 1:
          Navigator.pushReplacementNamed(context, HomeScreen.route);
          break;

        case 2:
          Navigator.pushReplacementNamed(context, OptionsScreen.route);
          break;
      }
    },
    items: const <BottomNavigationBarItem>[
      BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Options'),
    ],
    selectedItemColor: AppColors.selectedColor,
  );
}
