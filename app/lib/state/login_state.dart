import 'package:app/models/login_data.dart';
import 'package:flutter/material.dart';

class LoginState extends ChangeNotifier {
  LoginData data;

  LoginState({required this.data});

  void setLoginData(LoginData updatedLoginData) {
    data = updatedLoginData;
    notifyListeners();
  }
}
