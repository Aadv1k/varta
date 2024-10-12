import 'dart:convert';

import 'package:app/common/exceptions.dart';
import 'package:app/models/user_model.dart';
import 'package:app/services/api_service.dart';
import 'package:app/services/shared_pref_service.dart';

import 'package:http/http.dart' as http;

class UserRepository {
  final SharedPrefService _sharedPref = SharedPrefService();
  final ApiService _apiService = ApiService();

  UserRepository();

  Future<List<UserModel>> getTeachers() async {
    return [];
  }

  Future<UserModel> getUser() async {
    http.Response response = await _apiService
        .makeRequest(HTTPMethod.GET, "/me", isAuthenticated: true);

    if (response.statusCode != 200) {
      throw ApiException.fromResponse(response);
    }

    try {
      var data = jsonDecode(response.body)["data"];
      var user = UserModel.fromJson(data);

      return user;
    } on FormatException {
      throw ApiException(
          "We received an unexpected response from the server. Please try again later, or contact support if the issue persists.",
          {});
    }
  }
}
