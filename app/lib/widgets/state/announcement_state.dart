import 'package:app/models/announcement_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class AnnouncementState extends ChangeNotifier {
  List<AnnouncementModel> announcements = [];
  bool announcementsLoaded = false;

  List<AnnouncementModel> userAnnouncements = [];
  bool userAnnouncementsLoaded = false;

  void addAnnouncements(List<AnnouncementModel> announcement) {
    announcements.addAll(announcement);
    notifyListeners();
  }

  void setAnnouncementsLoaded() {
    announcementsLoaded = true;
  }

  void setUserAnouncementsLoaded() {
    userAnnouncementsLoaded = true;
  }

  void addUserAnnouncements(List<AnnouncementModel> announcement) {
    userAnnouncements.addAll(announcement);
    notifyListeners();
  }

  void deleteLatestAnnouncement() {
    announcements = announcements.slice(1, announcements.length);
  }
}
