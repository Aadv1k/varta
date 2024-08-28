import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:app/common/styles.dart';
import 'package:app/models/login_data.dart';
import 'package:app/providers/login_provider.dart';
import 'package:app/screens/otp_verification.dart';
import 'package:app/screens/phone_login.dart';
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
                    color: Colors.black, fontWeight: FontWeight.bold)),
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(AppStyles.buttonRadius)))),
          ),
          textTheme: TextTheme(
              displayLarge: AppStyles.displayLarge,
              headlineLarge: AppStyles.headlineLarge,
              headlineMedium: AppStyles.headlineMedium,
              headlineSmall: AppStyles.headlineSmall,
              bodyLarge: AppStyles.bodyLarge,
              bodyMedium: AppStyles.bodyMedium,
              labelMedium: AppStyles.labelMedium),
          useMaterial3: true,
        ),
        home: LoginProvider(
          loginState: LoginState(
              data: LoginData(
                  schoolIDAndName: ("1234", "Delhi Public School, Noida"),
                  inputType: LoginType.phoneNumber,
                  inputData: "+912086213307")),
          child: const OTPVerification(),
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