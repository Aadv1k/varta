import 'dart:js_interop_unsafe';

import 'package:app/common/varta_theme.dart';
import 'package:app/models/login_data.dart';
import 'package:app/screens/announcement_inbox/mobile/announcement_inbox.dart';
import 'package:app/screens/welcome/welcome.dart';
import 'package:app/services/token_service.dart';
import 'package:app/widgets/connection_error.dart';
import 'package:app/widgets/providers/app_provider.dart';
import 'package:app/widgets/providers/login_provider.dart';
import 'package:app/widgets/state/app_state.dart';
import 'package:app/widgets/state/login_state.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const VartaApp());
}

class VartaApp extends StatelessWidget {
  const VartaApp({
    super.key,
  });

  Future<bool> _shouldShowLogin() async {
    var tokenService = TokenService();
    final accessToken = await tokenService.getAccessToken();

    if (accessToken == null ||
        tokenService.tokenExpiredOrInvalid(accessToken)) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Varta',
        theme: VartaTheme().data,
        home: FutureBuilder(
            future: _shouldShowLogin(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Placeholder();
              }

              if (snapshot.hasError) {
                return GenericError(
                  errorMessage: snapshot.error.toString(),
                );
              }

              final shouldShowLogin = snapshot.data!;
              if (shouldShowLogin) {
                return LoginProvider(
                  state: LoginState(data: LoginData()),
                  child: const WelcomeScreen(),
                );
              }

              return FutureBuilder(
                future: AppState.initialize(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Placeholder();
                  }
                  if (snapshot.hasError) {
                    return GenericError(
                      errorMessage: snapshot.error.toString(),
                    );
                  }
                  return AppProvider(
                    state: snapshot.data!,
                    child: const AnnouncementInboxScreen(),
                  );
                },
              );
            }));
  }
}
