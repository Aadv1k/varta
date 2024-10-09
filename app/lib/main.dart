import 'dart:ui';

import 'package:app/common/varta_theme.dart';
import 'package:app/models/login_data.dart';
import 'package:app/screens/announcement_creation/create_announcement_screen.dart';
import 'package:app/screens/announcement_inbox/mobile/announcement_feed.dart';
import 'package:app/screens/login/phone_login.dart';
import 'package:app/screens/welcome/welcome.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/services/token_service.dart';
import 'package:app/widgets/providers/login_provider.dart';
import 'package:app/widgets/state/login_state.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  var isLoggedIn = false;

  final tokenService = TokenService();

  var accessToken = await tokenService.getAccessToken();

  if (accessToken != null) {
    isLoggedIn = true;
  }

  runApp(VartaApp(
    isLoggedIn: isLoggedIn,
  ));
}

class VartaApp extends StatelessWidget {
  final bool isLoggedIn;

  const VartaApp({
    super.key,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Varta',
        theme: VartaTheme().data,
        home: isLoggedIn
            ? const AnnouncementInbox()
            : LoginProvider(
                loginState: LoginState(data: LoginData()),
                child: const WelcomeScreen(),
              ));
  }
}
