import 'package:flutter/material.dart';

FormFieldValidator validateService() {
  return (value) {
    String patttern = r'(^[a-zA-Z0-9\- ]*$)';
    RegExp regExp = RegExp(patttern);
    if (value!.isEmpty) {
      return "Service is required!";
    } else if (!regExp.hasMatch(value)) {
      return "Service must contain characters from a-z, A-Z or 0-9.";
    } else {
      return null;
    }
  };
}

FormFieldValidator validatePassword() {
  return (value) {
    if (value!.isEmpty) {
      return "Password is required!";
    } else {
      return null;
    }
  };
}

FormFieldValidator validateMaster() {
  return (value) {
    if (value!.isEmpty) {
      return "Master is required!";
    } else {
      return null;
    }
  };
}
