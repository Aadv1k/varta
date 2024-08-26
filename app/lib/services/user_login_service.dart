import 'package:app/models/user.dart';
import 'package:flutter/material.dart';

class UserLoginService extends ChangeNotifier {
  UserLoginData loginData;

  UserLoginService({required this.loginData});

  void setLoginData(UserLoginData data) {
    loginData = data;
    notifyListeners();
  }
}
