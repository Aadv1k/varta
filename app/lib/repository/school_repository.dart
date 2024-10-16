import 'dart:convert';

import 'package:app/common/exceptions.dart';
import 'package:app/models/announcement_model.dart';
import 'package:app/models/school_model.dart';
import 'package:app/models/user_model.dart';
import 'package:app/services/api_service.dart';
import 'package:app/services/simple_cache_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SchoolRepository {
  final ApiService _apiService = ApiService();
  SimpleCacheService _cacheService = SimpleCacheService();
  final _sharedPrefs = SharedPreferencesAsync();

  Future<List<SchoolModel>> getSchools() async {
    String? foundCache = await _sharedPrefs.getString("schoolListData");

    if (foundCache != null) {
      final data = jsonDecode(foundCache);

      DateTime cachedAt = DateTime.fromMillisecondsSinceEpoch(data["cachedAt"]);
      if (cachedAt.add(const Duration(days: 1)).isAfter(DateTime.now())) {
        final List<dynamic> cachedData = data["data"];
        final List<SchoolModel> parsedData = cachedData
            .map((jsonItem) => SchoolModel.fromJson(jsonItem))
            .toList();

        return parsedData;
      }
    }

    final response = await _apiService.makeRequest(HTTPMethod.GET, "/schools");
    if (response.statusCode != 200) {
      throw ApiException.fromResponse(response);
    }
    final data = jsonDecode(response.body);
    final List<SchoolModel> parsedData =
        (data["data"] as List).map((s) => SchoolModel.fromJson(s)).toList();

    if (parsedData.isEmpty) {
      throw ApiException(
          "Received empty school list, this is likely a bug. Please try again later",
          {});
    }

    await _sharedPrefs.setString(
      "schoolListData",
      jsonEncode({
        "cachedAt": DateTime.now().millisecondsSinceEpoch,
        "data": parsedData.map((school) => school.toJson()).toList()
      }),
    );

    return parsedData;
  }

  Future<List<UserModel>> getTeachers() async {
    var foundCache = await _cacheService.fetchOrNull("teachers");

    if (foundCache != null) {
      return (jsonDecode(foundCache.data) as List)
          .map((teacherData) => UserModel.fromJson(teacherData))
          .toList();
    }

    http.Response response = await _apiService.makeRequest(
        HTTPMethod.GET, "/schools/teachers",
        isAuthenticated: true);

    if (response.statusCode != 200) {
      throw ApiException(
          "Something went wrong when trying to fetch the teachers. Please try again later.",
          {});
    }

    var data = jsonDecode(response.body);
    List<UserModel> parsedData = (data["data"] as List)
        .map((teacherData) =>
            UserModel.fromJson({...teacherData, "contacts": []}))
        .toList();

    if (parsedData.isEmpty) {
      throw ApiException(
          "Received empty teacher list, this is likely a bug. Please try again later",
          {});
    }

    await _cacheService.store(
        "teachers",
        jsonEncode(
            parsedData.map((teacherData) => teacherData.toJson()).toList()));

    return parsedData;
  }
}
