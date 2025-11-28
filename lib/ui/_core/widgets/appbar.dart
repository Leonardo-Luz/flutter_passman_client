import 'package:flutter/material.dart';
import 'package:flutter_passman_client/ui/_core/app_colors.dart';

AppBar getAppBar({String? title}) {
  return AppBar(
    title: title != null ? Text(title) : null,
    centerTitle: true,
  );
}
