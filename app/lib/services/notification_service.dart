import 'package:app/common/exceptions.dart';
import 'package:app/services/auth_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final AuthService _authService = AuthService();
  SharedPreferencesAsync prefs = SharedPreferencesAsync();

  Future<bool> didAllowNotifications() async {
    return (await prefs.getBool("hasAllowedNotifications")) ?? false;
  }

  Future initNotifications(String contactData) async {
    try {
      final permission = await firebaseMessaging.requestPermission(alert: true);

      if (permission.authorizationStatus != AuthorizationStatus.authorized) {
        await prefs.setBool("hasAllowedNotifications", false);
        return;
      }

      String? fcmToken = await firebaseMessaging.getToken();

      if (fcmToken == null) {
        throw ApiClientException("FCM token retrieval failed");
      }

      await _authService.registerDevice(fcmToken, contactData);
      await prefs.setBool("hasAllowedNotifications", true);

      await firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      throw ApiClientException(
          "Failed to initialize notifications: ${e.toString()}");
    }
  }
}
