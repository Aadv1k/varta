import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:app/common/const.dart';
import 'package:app/common/exceptions.dart';
import 'package:app/models/announcement_model.dart';
import 'package:app/models/search_data.dart';
import 'package:app/services/api_service.dart';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

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

  Future<String> getPresignedAttachmentUrl(String attachmentId) async {
    final response = await _apiService.makeRequest(
        HTTPMethod.GET, "/attachments/$attachmentId",
        isAuthenticated: true);

    if (response.statusCode != 200) {
      throw ApiException.fromResponse(response);
    }

    return jsonDecode(response.body)["data"]["url"];
  }

  Future<Uint8List> downloadAttachment(String url) async {
    throw AssertionError("Not implemented");
  }

  Future<AnnouncementAttachmentModel> uploadAttachment(
      AttachmentSelectionData data) async {
    var file = File(data.filePath!);

    final fileType = data.fileType.mime.split("/");
    String prefix = fileType.first;
    String suffix = fileType.last;

    try {
      final request = http.MultipartRequest(
          "POST", Uri.parse("$baseApiUrl/attachments/upload"));
      request.headers.addAll(await _apiService.getAuthHeaders());
      request.files.add(await http.MultipartFile.fromPath("file", file.path,
          contentType: MediaType(prefix, suffix)));

      final response = await http.Response.fromStream(await request.send());

      if (response.statusCode != 201) {
        throw ApiException.fromResponse(response);
      }

      var responseData = jsonDecode(response.body);
      return AnnouncementAttachmentModel.fromJson(responseData["data"]);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiClientException(e.toString());
    }
  }

  Future<AnnouncementModel> createAnnouncement(
      AnnouncementCreationData creationData) async {
    try {
      List<String> attachmentIds = [];

      for (final attachmentData in creationData.attachments) {
        final attachmentModel = await uploadAttachment(attachmentData);
        attachmentIds.add(attachmentModel.id);
      }

      http.Response response = await _apiService.makeRequest(
          HTTPMethod.POST, "/announcements/",
          isAuthenticated: true,
          body: {
            "title": creationData.title,
            "body": creationData.body,
            "scopes": creationData.scopes
                .map((scope) => scope.toAnnouncementScope().toJson())
                .toList(),
            "attachments": attachmentIds
          });

      if (response.statusCode != 201) {
        throw ApiException.fromResponse(response);
      }
      var data = jsonDecode(response.body)["data"];
      return AnnouncementModel.fromJson(data);
    } on ApiClientException catch (_) {
      rethrow;
    }
  }

  Future<void> deleteAnnouncement(AnnouncementModel announcement) async {
    try {
      final http.Response response = await _apiService.makeRequest(
          HTTPMethod.DELETE, "/announcements/${announcement.id}",
          isAuthenticated: true);

      if (response.statusCode != 204) {
        throw ApiException.fromResponse(response);
      }
    } on ApiClientException catch (_) {
      rethrow;
    }
  }

  // TODO: this is a bit sus
  Future<AnnouncementModel> updateAnnouncement(
      AnnouncementModel oldAnnouncement, AnnouncementCreationData data) async {
    try {
      List<String> newAttachmentIds = [];
      List<String> existingAttachmentIds = [];

      for (final attachmentData in data.attachments) {
        // This means the attachment is the old attachment and it isn't removed. So for this we will simply add it to the new list
        // TODO: do some further testing to see how this will behave with expiring signed URLs
        if (attachmentData.id != null) {
          final existingAttachmentId = oldAnnouncement.attachments
              .firstWhere((attachment) => attachment.id == attachmentData.id!)
              .id;
          existingAttachmentIds.add(existingAttachmentId);
          continue;
        }

        final attachment = await uploadAttachment(attachmentData);
        newAttachmentIds.add(attachment.id);
      }

      final http.Response response = await _apiService.makeRequest(
          HTTPMethod.PUT, "/announcements/${oldAnnouncement.id}",
          body: {
            "title": data.title,
            "body": data.body,
            "scopes": data.scopes
                .map((scope) => scope.toAnnouncementScope().toJson())
                .toList(),
            "attachments": [...existingAttachmentIds, ...newAttachmentIds]
          },
          isAuthenticated: true);

      if (response.statusCode != 200) {
        throw ApiException.fromResponse(response);
      }
      return AnnouncementModel.fromJson(jsonDecode(response.body)["data"]);
    } on ApiClientException catch (_) {
      rethrow;
    }
  }

  Future<List<AnnouncementModel>> searchAnnouncement(
      SearchData searchData) async {
    const String apiUrl = '$baseApiUrl/announcements/search';

    final Map<String, dynamic> queryParams = searchData.toQueryParameters();
    final Uri uri = Uri.parse(apiUrl).replace(queryParameters: queryParams);
    var hackyFix = uri.toString().replaceAll(RegExp(baseApiUrl), "");

    try {
      final http.Response response = await _apiService
          .makeRequest(HTTPMethod.GET, hackyFix, isAuthenticated: true);

      if (response.statusCode != 200) {
        throw ApiException.fromResponse(response);
      }
      final List<dynamic> data = json.decode(response.body)["data"]["results"];
      return data.map((json) => AnnouncementModel.fromJson(json)).toList();
    } on ApiClientException catch (_) {
      rethrow;
    }
  }
}
