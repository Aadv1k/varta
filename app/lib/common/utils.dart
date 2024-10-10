import 'dart:convert';

import 'package:app/models/login_data.dart';
import 'package:app/screens/welcome/welcome.dart';
import 'package:app/widgets/providers/login_provider.dart';
import 'package:app/widgets/state/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

dynamic loadJsonFromAssetFile(String fileName) async {
  String data = await rootBundle.loadString(fileName);
  return jsonDecode(data);
}

void clearAndNavigateBackToLogin(BuildContext context) {
  Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => LoginProvider(
              state: LoginState(data: LoginData()),
              child: const WelcomeScreen())),
      (_) => false);
}
