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

class VartaApp extends StatefulWidget {
  const VartaApp({
    super.key,
  });

  @override
  State<VartaApp> createState() => _VartaAppState();
}

class _VartaAppState extends State<VartaApp> {
  late Future<AppState?> _initializedApp;

  Future<AppState?> _initializeApp() async {
    var tokenService = TokenService();
    final accessToken = await tokenService.getAccessToken();

    if (accessToken == null ||
        tokenService.tokenExpiredOrInvalid(accessToken)) {
      return null;
    }

    try {
      var appState = await AppState.initialize();
      return appState;
    } catch (exc) {
      return null;
    }
  }

  @override
  void initState() {
    _initializedApp = _initializeApp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Varta',
        theme: VartaTheme().data,
        home: FutureBuilder(
            future: _initializedApp,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Placeholder();
              }

              if (snapshot.hasError) {
                return GenericError(
                  errorMessage: snapshot.error.toString(),
                );
              }

              final appState = snapshot.data;
              if (appState == null) {
                return LoginProvider(
                  state: LoginState(data: LoginData()),
                  child: const WelcomeScreen(),
                );
              }

              return AppProvider(
                state: appState,
                child: const AnnouncementInboxScreen(),
              );
              ;
            }));
  }
}
