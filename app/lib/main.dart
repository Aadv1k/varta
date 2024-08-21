import 'dart:collection';
import 'dart:io';

import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:app/screens/welcome.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Varta',
      theme: ThemeData(
        elevatedButtonTheme: const ElevatedButtonThemeData(
            style: ButtonStyle(
                backgroundColor:
                    WidgetStatePropertyAll(AppColors.darkPrimaryColor),
                textStyle: WidgetStatePropertyAll(TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)))),
        textTheme: const TextTheme(
            labelMedium:
                TextStyle(fontSize: FontSizes.textBase, color: Colors.black),
            displayLarge: TextStyle(
                fontSize: FontSizes.text4xl,
                height: 1.5,
                fontWeight: FontWeight.w900,
                color: AppColors.heading),
            headlineMedium: TextStyle(
                fontSize: FontSizes.textLg,
                fontWeight: FontWeight.bold,
                color: AppColors.heading),
            bodyLarge: TextStyle(
                fontSize: FontSizes.textLg,
                fontWeight: FontWeight.normal,
                color: AppColors.body),
            bodyMedium: TextStyle(
                fontSize: FontSizes.textBase,
                fontWeight: FontWeight.normal,
                color: AppColors.body)),
        useMaterial3: true,
      ),
      home: const InitialScreen(),
    );
  }
}

/*
At the time of initialization we do the following

- Check if the an access or refresh token exists
  - if it doesn't and it is first time user login we show "welcome screen"
  - if it doesn't and it isn't first time then we show "phone login screen" 
- Make sure the access token is valid
  - if it is not then fetch new one using refresh token
    - if refresh token isn't valid show "phone login screen"
- Render the "home screen"
*/

class AuthTokenPair {
  final String accessToken;
  final String refreshToken;

  AuthTokenPair({required this.accessToken, required this.refreshToken});
}

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  bool _hasTokenPair() {
    return false;
  }

  bool _isFirstLogin() {
    return true;
  }

  bool _hasValidTokenPair() {
    return false;
  }

  AuthTokenPair? _tryAndRenewAuthTokenPair() {
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasTokenPair()) {
      if (_isFirstLogin()) {
        return const WelcomeScreen();
      } else {
        // TODO: take the user directly to login screen
      }
    } else {
      if (_hasValidTokenPair()) {
        // TODO: take the user to the home screen
      } else {
        AuthTokenPair? tokenPair = _tryAndRenewAuthTokenPair();
        if (tokenPair == null) {
          // TODO: take the user to login screen
        } else {
          // TODO: take the user to home screen
        }
      }
    }

    throw UnimplementedError("Unreachable");
  }
}
