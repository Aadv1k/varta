import 'package:app/state/login_state.dart';
import 'package:flutter/material.dart';

class LoginProvider extends InheritedWidget {
  final LoginState loginState;

  const LoginProvider(
      {super.key, required this.loginState, required super.child});

  static LoginProvider of(BuildContext context) {
    return context.getInheritedWidgetOfExactType<LoginProvider>()!;
  }

  @override
  bool updateShouldNotify(covariant LoginProvider oldWidget) {
    return oldWidget.loginState.data != loginState.data;
  }
}
