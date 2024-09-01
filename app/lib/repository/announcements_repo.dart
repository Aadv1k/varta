import 'package:app/models/announcement_model.dart';
import 'package:app/services/api_service.dart';

class AnnouncementsRepository {
  final ApiService _apiService = ApiService();

  Future<List<AnnouncementModel>> getAnnouncements() {}
}
