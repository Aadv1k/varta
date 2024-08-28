import 'package:flutter/material.dart';

class UserData {}

class LoginData extends ChangeNotifier {
  LoginData userData;

  LoginData({required this.data});

  void setLoginData(LoginData updatedLoginData) {
    data = updatedLoginData;
    notifyListeners();
  }
}
