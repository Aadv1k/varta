import 'package:app/common/exceptions.dart';
import 'package:app/services/auth_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final AuthService _authService = AuthService();
  SharedPreferencesAsync prefs = SharedPreferencesAsync();

  Future<NotificationSettings> get notificationSettings async =>
      await firebaseMessaging.requestPermission(alert: true);

  Future initNotifications(String contactData) async {
    try {
      final status = (await notificationSettings).authorizationStatus;

      if (status != AuthorizationStatus.authorized) return;

      String? fcmToken = await firebaseMessaging.getToken();

      if (fcmToken == null) {
        throw ApiClientException("FCM token retrieval failed");
      }

      await _authService.registerDevice(fcmToken, contactData);

      await firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      firebaseMessaging.onTokenRefresh.listen((token) async {
        print("HELLO WORLD!!!!");
        await _authService.registerDevice(token, contactData);
      });
    } catch (e) {
      throw ApiClientException(
          "Failed to initialize notifications: ${e.toString()}");
    }
  }
}
