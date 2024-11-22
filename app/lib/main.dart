import 'package:app/common/const.dart';
import 'package:app/common/varta_theme.dart';
import 'package:app/firebase_options.dart';
import 'package:app/models/login_data.dart';
import 'package:app/screens/announcement_inbox/mobile/announcement_inbox.dart';
import 'package:app/screens/welcome/welcome.dart';
import 'package:app/services/notification_service.dart';
import 'package:app/services/token_service.dart';
import 'package:app/widgets/error_snackbar.dart';
import 'package:app/widgets/generic_error_box.dart';
import 'package:app/widgets/providers/app_provider.dart';
import 'package:app/widgets/providers/login_provider.dart';
import 'package:app/widgets/state/app_state.dart';
import 'package:app/widgets/state/login_state.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

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
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: firebaseConfig["apiKey"]!,
            authDomain: firebaseConfig["authDomain"]!,
            storageBucket: firebaseConfig["storageBucket"]!,
            appId: firebaseConfig["appId"]!,
            messagingSenderId: firebaseConfig["messagingSenderId"]!,
            projectId: firebaseConfig["projectId"]!));

    var tokenService = TokenService();
    final accessToken = await tokenService.getAccessToken();

    if (accessToken == null ||
        tokenService.tokenExpiredOrInvalid(accessToken)) {
      return null;
    }

    AppState appState = await AppState.initialize();
    try {
      NotificationService service = NotificationService();

      final settings =
          await service.firebaseMessaging.getNotificationSettings();

      if (settings.authorizationStatus != AuthorizationStatus.denied) {
        if (appState.user?.contacts != null &&
            appState.user!.contacts.isNotEmpty) {
          await service
              .initNotifications(appState.user!.contacts.first.contactData);
        }
      }
    } catch (exc) {
      /* PASS */
    }

    return appState;
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
        debugShowCheckedModeBanner: false,
        theme: VartaTheme().data,
        home: FutureBuilder(
            future: _initializedApp,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              }

              FlutterNativeSplash.remove();

              if (snapshot.hasError) {
                return GenericErrorBox(
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
                  state: appState, child: const AnnouncementInboxScreen());
            }));
  }
}
