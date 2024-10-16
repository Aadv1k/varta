import 'dart:convert';

import 'package:app/common/exceptions.dart';
import 'package:app/models/announcement_model.dart';
import 'package:app/models/search_data.dart';
import 'package:app/screens/announcement_creation/create_announcement_screen.dart';
import 'package:app/services/api_service.dart';

import 'package:http/http.dart' as http;

class AnnouncementIncrementalChange {
  int timeStamp;
  List<AnnouncementModel> created;
  List<AnnouncementModel> deleted;
  List<AnnouncementModel> updated;

  AnnouncementIncrementalChange(
      this.timeStamp, this.created, this.deleted, this.updated);
}

class PaginatedAnnouncementModelList {
  int pageNumber;
  int maxPages;
  List<AnnouncementModel> data;

  PaginatedAnnouncementModelList(this.pageNumber, this.maxPages, this.data);
}

class AnnouncementsRepository {
  final ApiService _apiService = ApiService();

  Future<PaginatedAnnouncementModelList> getAnnouncements(
      {int page = 1, bool isUserAnnouncement = false}) async {
    http.Response response;

    if (!isUserAnnouncement) {
      response = await _apiService.makeRequest(
          HTTPMethod.GET, "/announcements?page=$page",
          isAuthenticated: true);
    } else {
      response = await _apiService.makeRequest(
          HTTPMethod.GET, "/announcements/mine?page=$page",
          isAuthenticated: true);
    }

    if (response.statusCode != 200) {
      throw ApiException.fromResponse(response);
    }

    var data = jsonDecode(response.body);

    List<AnnouncementModel> parsedData = (data["data"] as List)
        .map((element) => AnnouncementModel.fromJson(element))
        .toList();

    return PaginatedAnnouncementModelList(data["metadata"]["page_number"],
        data["metadata"]["total_pages"], parsedData);
  }

  Future<AnnouncementIncrementalChange> fetchLatestChanges(
      int timeSince) async {
    http.Response response = await _apiService.makeRequest(
        HTTPMethod.GET, "/announcements/updated-since?timestamp=$timeSince",
        isAuthenticated: true);
    if (response.statusCode != 200) {
      throw ApiException.fromResponse(response);
    }

    var data = jsonDecode(response.body)["data"];

    return AnnouncementIncrementalChange(
      timeSince,
      (data["new"] as List)
          .map((elem) => AnnouncementModel.fromJson(elem))
          .toList(),
      (data["deleted"] as List)
          .map((elem) => AnnouncementModel.fromJson(elem))
          .toList(),
      (data["updated"] as List)
          .map((elem) => AnnouncementModel.fromJson(elem))
          .toList(),
    );
  }

  Future<AnnouncementModel> createAnnouncement(
      AnnouncementCreationData creationData) async {
    try {
      http.Response response = await _apiService.makeRequest(
          HTTPMethod.POST, "/announcements/",
          isAuthenticated: true,
          body: {
            "title": creationData.title,
            "body": creationData.body,
            "scopes": creationData.scopes
                .map((scope) => scope.toAnnouncementScope().toJson())
                .toList(),
          });
      if (response.statusCode != 201) {
        ApiException.fromResponse(response);
      }

      var data = jsonDecode(response.body)["data"];
      return AnnouncementModel.fromJson(data);
    } on ApiClientException catch (_) {
      rethrow;
    }
  }

  Future<void> deleteAnnouncement(AnnouncementModel announcement) {
    throw UnimplementedError();
  }

  Future<void> updateAnnouncement(AnnouncementModel announcement) {
    throw UnimplementedError();
  }

  Future<List<AnnouncementModel>> searchAnnouncement(SearchData data) {
    throw UnimplementedError();
  }
}
