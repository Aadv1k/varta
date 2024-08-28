import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:app/models/login_data.dart';
import 'package:app/providers/login_provider.dart';
import 'package:app/screens/welcome.dart';
import 'package:app/state/login_state.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  runApp(const VartaApp(
    isFirstTimeLogin: true,
    isLoggedIn: false,
  ));
}

class VartaApp extends StatelessWidget {
  final bool isLoggedIn;
  final bool isFirstTimeLogin;

  const VartaApp({
    super.key,
    required this.isLoggedIn,
    required this.isFirstTimeLogin,
  });

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
              displaySmall: TextStyle(
                  fontSize: FontSizes.textBase,
                  fontWeight: FontWeight.bold,
                  color: AppColors.heading),
              headlineMedium: TextStyle(
                  fontSize: FontSizes.textLg,
                  fontWeight: FontWeight.bold,
                  color: AppColors.heading),
              headlineLarge: TextStyle(
                  fontSize: FontSizes.text2xl,
                  fontWeight: FontWeight.w900,
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
        home: LoginProvider(
          loginState: LoginState(data: LoginData()),
          child: const WelcomeScreen(),
        )

        // LoginProvider(
        //     loginState: LoginState(data: LoginData()),
        //     child: const WelcomeScreen())

        // !isLoggedIn
        //     ? (isFirstTimeLogin
        //         ? const WelcomeScreen()
        //         : PhoneLogin(
        //             userLoginData: UserLoginData(),
        //           ))
        //     : const Placeholder(),
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