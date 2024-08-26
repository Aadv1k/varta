import 'dart:convert';

import 'package:app/models/school_model.dart';
import 'package:app/services/api_service.dart';
import 'package:app/services/auth_service.dart';

class SchoolRepository {
  final ApiService _apiService = ApiService();

  Future<List<SchoolModel>> getSchools() async {
    String? foundCache = AuthService.sharedPrefs.getString("schoolListData");

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

    final response = await _apiService.get("/schools");
    final data = jsonDecode(response.body);

    final List<dynamic> responseData = data["data"];
    final List<SchoolModel> parsedData =
        responseData.map((jsonItem) => SchoolModel.fromJson(jsonItem)).toList();

    AuthService.sharedPrefs.setString(
      "schoolListData",
      jsonEncode({
        "cachedAt": DateTime.now().millisecondsSinceEpoch,
        "data": parsedData.map((school) => school.toJson()).toList()
      }),
    );

    return parsedData;
  }
}
