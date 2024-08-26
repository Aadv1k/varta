import 'package:app/services/user_login_service.dart';
import 'package:flutter/material.dart';

class UserLoginProvider extends InheritedWidget {
  final UserLoginService userLoginService;

  const UserLoginProvider(
      {super.key, required this.userLoginService, required super.child});

  @override
  bool updateShouldNotify(covariant UserLoginProvider oldWidget) {
    return oldWidget.userLoginService.loginData != userLoginService.loginData;
  }

  static UserLoginProvider of(BuildContext context) {
    return context.getInheritedWidgetOfExactType<UserLoginProvider>()!;
  }
}
