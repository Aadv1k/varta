import 'package:app/common/const.dart';
import 'package:app/common/exceptions.dart';
import 'package:app/services/auth_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final AuthService _authService = AuthService();
  SharedPreferencesAsync prefs = SharedPreferencesAsync();

  Future initNotifications(String contactData) async {
    try {
      final status = (await firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: true,
        sound: true,
      ))
          .authorizationStatus;

      if (status != AuthorizationStatus.authorized) return;

      String? fcmToken = await firebaseMessaging.getToken(
          vapidKey: kIsWeb ? webVapidKey : null);

      FirebaseMessaging.instance.setAutoInitEnabled(true);

      // just run this in apple platforms. Well ideally we should check the platform here but it appears we can't.
      await firebaseMessaging.getAPNSToken();

      if (fcmToken == null) {
        throw ApiClientException("FCM token retrieval failed");
      }

      await _authService.registerDevice(fcmToken, contactData);
    } catch (e, stackTrace) {
      throw ApiClientException(
          "Failed to initialize notifications: ${e.toString()} ${stackTrace.toString()}");
    }
  }
}
