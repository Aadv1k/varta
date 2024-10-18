import 'package:app/common/exceptions.dart';
import 'package:app/services/auth_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final AuthService _authService = AuthService();
  SharedPreferencesAsync prefs = SharedPreferencesAsync();

  Future<bool> didAllowNotifications() async {
    return (await prefs.getBool("hasAllowedNotifications")) ?? false;
  }

  Future initNotifications(String contactData) async {
    try {
      final permission = await _firebaseMessaging.requestPermission();

      if (permission.authorizationStatus != AuthorizationStatus.authorized) {
        await prefs.setBool("hasAllowedNotifications", false);
        return;
      }

      String? fcmToken;
      if (kIsWeb) {
        fcmToken = await _firebaseMessaging.getToken();
      } else {
        fcmToken = await _firebaseMessaging.getToken();
      }

      if (fcmToken == null) {
        throw ApiClientException("FCM token retrieval failed");
      }

      await _authService.registerDevice(fcmToken, contactData);
      await prefs.setBool("hasAllowedNotifications", true);
    } catch (e) {
      throw ApiClientException(
          "Failed to initialize notifications: ${e.toString()}");
    }
  }
}
