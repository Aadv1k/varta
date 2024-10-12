import 'dart:convert';

import 'package:app/models/announcement_model.dart';
import 'package:app/models/user_model.dart';
import 'package:app/services/simple_cache_service.dart';
import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  List<AnnouncementModel> announcements;
  List<AnnouncementModel> userAnnouncements;
  UserModel? user;

  AppState({
    List<AnnouncementModel>? announcements,
    List<AnnouncementModel>? userAnnouncements,
    this.user,
  })  : announcements = announcements ?? [],
        userAnnouncements = userAnnouncements ?? [];

  void setUser(UserModel? newUser) {
    user = newUser;
    notifyListeners();
  }

  void setAnnouncements(List<AnnouncementModel> newAnnouncements,
      {bool isUserAnnouncement = false}) {
    if (isUserAnnouncement) {
      userAnnouncements = newAnnouncements;
    } else {
      announcements = newAnnouncements;
    }
    notifyListeners();
  }

  static Future<AppState> initialize({UserModel? user}) async {
    SimpleCacheService cacheService = SimpleCacheService();

    UserModel? foundUser;
    if (user == null) {
      final userCache = await cacheService.fetchOrNull("user");

      if (userCache != null) {
        foundUser = UserModel.fromJson(jsonDecode(userCache.data));
      }
    }

    final announcementCache = await cacheService.fetchOrNull("announcements");
    List<AnnouncementModel> announcementData = [];

    if (announcementCache != null) {
      announcementData = (announcementCache.data as List)
          .map((elem) => AnnouncementModel.fromJson(elem))
          .toList();
    }

    return AppState(announcements: announcementData, user: foundUser ?? user);
  }
}
