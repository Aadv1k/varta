import 'dart:convert';

import 'package:app/common/exceptions.dart';
import 'package:app/models/school_model.dart';
import 'package:app/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SchoolRepository {
  final ApiService _apiService = ApiService();
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
}
