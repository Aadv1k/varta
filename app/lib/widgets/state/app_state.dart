import 'dart:convert';

import 'package:app/models/announcement_model.dart';
import 'package:app/models/user_model.dart';
import 'package:app/repository/user_repo.dart';
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

  void addAnnouncements(List<AnnouncementModel> newAnnouncements,
      {bool isUserAnnouncement = false}) {
    if (isUserAnnouncement) {
      userAnnouncements.addAll(newAnnouncements);
    } else {
      announcements.addAll(newAnnouncements);
    }
    notifyListeners();
  }

  void removeAt(int index, {bool isUserAnnouncement = false}) {
    if (isUserAnnouncement) {
      userAnnouncements.removeAt(index);
    } else {
      announcements.removeAt(index);
    }
    notifyListeners();
  }

  void prependAnnouncements(List<AnnouncementModel> newAnnouncements,
      {bool isUserAnnouncement = false}) {
    if (isUserAnnouncement) {
      userAnnouncements = [...newAnnouncements, ...userAnnouncements];
    } else {
      announcements = [...newAnnouncements, ...announcements];
    }
    notifyListeners();
  }

  void saveAnnouncementState(
      {bool appendOnly = false, bool isUserAnnouncement = false}) async {
    var cacheService = SimpleCacheService();
    int? cachedAt;
    if (appendOnly) {
      if (isUserAnnouncement) {
        var userAnnouncementsCache =
            await cacheService.fetchOrNull("userAnnouncements");
        cachedAt = userAnnouncementsCache!.cachedAt;
      } else {
        var announcementsCache =
            await cacheService.fetchOrNull("announcements");
        cachedAt = announcementsCache!.cachedAt;
      }
    }

    if (isUserAnnouncement) {
      await SimpleCacheService().store("userAnnouncements",
          jsonEncode(userAnnouncements.map((ann) => ann.toJson()).toList()),
          cachedAt: cachedAt);
    } else {
      SimpleCacheService().store("announcements",
          jsonEncode(announcements.map((ann) => ann.toJson()).toList()),
          cachedAt: cachedAt);
    }
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

    UserModel? foundUser = user;

    if (foundUser == null) {
      final userCache = await cacheService.fetchOrNull("user");

      if (userCache == null) {
        assert(false,
            "It shouldn't be possible that the user is not set, yet the tokens are present");
      }

      foundUser = UserModel.fromJson(jsonDecode(userCache!.data));
    }

    final announcementCache = await cacheService.fetchOrNull("announcements");
    List<AnnouncementModel> announcementData = [];

    if (announcementCache != null) {
      announcementData = (jsonDecode(announcementCache.data) as List)
          .map((elem) => AnnouncementModel.fromJson(elem))
          .toList();
    }

    final userAnnouncementCache =
        await cacheService.fetchOrNull("userAnnouncements");
    List<AnnouncementModel> userAnnouncementData = [];

    if (userAnnouncementCache != null) {
      userAnnouncementData = (jsonDecode(userAnnouncementCache.data) as List)
          .map((elem) => AnnouncementModel.fromJson(elem))
          .toList();
    }

    return AppState(
        announcements: announcementData,
        user: foundUser,
        userAnnouncements: userAnnouncementData);
  }
}
