import 'package:app/common/varta_theme.dart';
import 'package:app/models/login_data.dart';
import 'package:app/screens/announcement_creation/create_announcement_screen.dart';
import 'package:app/widgets/providers/login_provider.dart';
import 'package:app/widgets/state/login_state.dart';
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
        theme: VartaTheme().data,
        home: LoginProvider(
          loginState: LoginState(data: LoginData()),
          child: const CreateAnnouncementScreen(),
        ));
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
