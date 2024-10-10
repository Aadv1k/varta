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

  void setUser(UserModel newUser) {
    user = newUser;
    notifyListeners();
  }

  void addAnnouncements(List<AnnouncementModel> announcement,
      {bool isUserAnnouncement = false}) {
    if (isUserAnnouncement) {
      userAnnouncements.addAll(announcement);
    } else {
      announcements.addAll(announcement);
    }
    notifyListeners();
  }

  static Future<AppState> initialize() async {
    SimpleCacheService cacheService = SimpleCacheService();

    final announcementCache = await cacheService.fetchOrNull("announcements");
    List<AnnouncementModel> announcementData = [];

    if (announcementCache != null) {
      announcementData = (announcementCache.data as List)
          .map((elem) => AnnouncementModel.fromJson(elem))
          .toList();
    }

    return AppState(
      announcements: announcementData,
    );
  }
}
