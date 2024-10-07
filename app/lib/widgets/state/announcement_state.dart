import 'package:app/models/announcement_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class AnnouncementState extends ChangeNotifier {
  List<AnnouncementModel> announcements = [];
  List<AnnouncementModel> yourAnnouncements = [];

  void addAnnouncements(List<AnnouncementModel> announcement) {
    announcements.addAll(announcement);
    notifyListeners();
  }

  void deleteLatestYourAnnouncement() {
    yourAnnouncements.removeLast();
    notifyListeners();
  }

  void addYourAnnouncements(List<AnnouncementModel> announcement) {
    yourAnnouncements.addAll(announcement);
    notifyListeners();
  }

  void deleteLatestAnnouncement() {
    announcements = announcements.slice(1, announcements.length);
  }
}
