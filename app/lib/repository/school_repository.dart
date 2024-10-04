import 'dart:convert';

import 'package:app/models/school_model.dart';
import 'package:app/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SchoolRepository {
  final ApiService _apiService = ApiService();
  final _sharedPrefs = SharedPreferencesAsync();

  Future<List<SchoolModel>> getSchools() async {
    if (kDebugMode) {
      return [
        SchoolModel(
            schoolId: 1234,
            schoolName: 'Bright Future Academy',
            schoolAddress: '123, Sai Baba Nagar, Mumbai, Maharashtra, 400001',
            schoolContactNo: '+912212345678',
            schoolEmail: 'foo@example.com')
      ];
    }

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
    final data = jsonDecode(response.body);

    final List<dynamic> responseData = data["data"];
    final List<SchoolModel> parsedData =
        responseData.map((jsonItem) => SchoolModel.fromJson(jsonItem)).toList();

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
