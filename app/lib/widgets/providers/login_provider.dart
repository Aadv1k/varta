import 'package:app/widgets/state/login_state.dart';
import 'package:flutter/material.dart';

class LoginProvider extends InheritedWidget {
  final LoginState state;

  const LoginProvider({super.key, required this.state, required super.child});

  static LoginProvider of(BuildContext context) {
    final provider = context.getInheritedWidgetOfExactType<LoginProvider>();
    if (provider == null) {
      throw AssertionError(
          "LoginProvider.of couldn't find the inhereted widget higher in the tree");
    }
    return provider;
  }

  @override
  bool updateShouldNotify(covariant LoginProvider oldWidget) {
    return oldWidget.state.data != state.data;
  }
}
