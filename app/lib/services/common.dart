import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const BASE_API_URL = "localhost:8000";

enum ApiEndpoint { userLogin, userVerify, userRefresh, user }

final Map<ApiEndpoint, String> apiEndpoints = {
  ApiEndpoint.userLogin: '/api/v1/me/login',
  ApiEndpoint.userVerify: '/api/v1/me/verify',
  ApiEndpoint.userRefresh: '/api/v1/me/refresh',
  ApiEndpoint.user: '/api/v1/me',
};

class ApiFieldError {
  final String field;
  final String error;

  ApiFieldError({required this.field, required this.error});

  factory ApiFieldError.fromJson(Map<String, dynamic> json) {
    return ApiFieldError(field: json["field"], error: json["error"]);
  }
}

class ApiException implements Exception {
  final String message;
  final List<ApiFieldError>? errors;

  ApiException({required this.message, this.errors});
}

class ApiService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<dynamic> fetch(ApiEndpoint endpoint,
      {Map<String, dynamic>? body}) async {
    final Uri url = Uri.http(BASE_API_URL, apiEndpoints[endpoint]!);

    final response = await http.post(url, body: body);
    final responseData = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw ApiException(
          message: responseData["message"],
          errors: responseData["errors"] != null
              ? (responseData["errors"] as List)
                  .map((e) => ApiFieldError.fromJson(e))
                  .toList()
              : null);
    }

    return responseData["data"];
  }

  Future<void> storeTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: "accessToken", value: accessToken);
    await _storage.write(key: "refreshToken", value: refreshToken);
  }

  Future<(String?, String?)> getTokens() async {
    return (
      await _storage.read(key: "accessToken"),
      await _storage.read(key: "refreshToken")
    );
  }
}
