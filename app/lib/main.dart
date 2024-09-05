import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:app/common/styles.dart';
import 'package:app/models/login_data.dart';
import 'package:app/providers/login_provider.dart';
import 'package:app/screens/announcement_inbox/mobile/home_screen.dart';
import 'package:app/screens/welcome/welcome.dart';
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
          scaffoldBackgroundColor: AppColor.primaryBg,
          chipTheme: ChipThemeData(
              deleteIconColor: AppColor.primaryBg,
              padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md, vertical: Spacing.sm),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                  side: const BorderSide(style: BorderStyle.none)),
              labelStyle: const VartaTextTheme().labelMedium,
              backgroundColor: AppColor.primaryColor),
          appBarTheme: const AppBarTheme(backgroundColor: AppColor.primaryBg),
          elevatedButtonTheme: const ElevatedButtonThemeData(
            style: ButtonStyle(
                backgroundColor:
                    WidgetStatePropertyAll(AppColor.darkPrimaryColor),
                textStyle: WidgetStatePropertyAll(TextStyle(
                    color: TWColor.neutral400, fontWeight: FontWeight.bold)),
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.all(AppSharedStyle.buttonRadius)))),
          ),
          textTheme: const VartaTextTheme(),
          useMaterial3: true,
        ),
        home: LoginProvider(
          loginState: LoginState(data: LoginData()),
          child: const HomeScreen(),
        )

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