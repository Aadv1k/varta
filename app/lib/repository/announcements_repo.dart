import 'package:app/models/announcement_model.dart';
import 'package:app/services/api_service.dart';

class AnnouncementsRepository {
  final ApiService _apiService = ApiService();

  Future<List<AnnouncementModel>> getAnnouncements({int page = 1}) {
    throw Exception("Not implemented");
  }

  Future<List<AnnouncementModel>> getMyAnnouncements({int page = 1}) {
    throw UnimplementedError();
  }

  Future<AnnouncementModel> createAnnouncement() {
    throw UnimplementedError();
  }

  Future<void> deleteAnnouncement() {
    throw UnimplementedError();
  }

  Future<void> updateAnnouncement() {
    throw UnimplementedError();
  }

  Future<(List<AnnouncementModel>, List<AnnouncementModel>)>
      searchAnnouncement() {
    throw UnimplementedError();
  }
}
