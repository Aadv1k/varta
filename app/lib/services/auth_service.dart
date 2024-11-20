import 'dart:convert';

import 'package:app/common/exceptions.dart';
import 'package:app/models/login_data.dart';
import 'package:app/services/api_service.dart';
import 'package:app/services/token_service.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final TokenService _tokenService = TokenService();

  Future<void> verifyOtp(LoginData data) async {
    final response = await _apiService.makeRequest(
      HTTPMethod.POST,
      "/me/verify",
      body: {
        "input_data": data.inputData,
        "school_id": data.schoolIDAndName!.$1,
        "otp": data.otp
      },
    );

    if (response.statusCode != 200) {
      throw ApiException.fromResponse(response);
    }

    try {
      final data = jsonDecode(response.body);

      _tokenService.storeAccessToken(data["data"]["access_token"]);
      _tokenService.storeRefreshToken(data["data"]["refresh_token"]);
    } catch (_) {
      throw ApiException(
          "We received an unexpected response from the server. Please try again later, or contact support if the issue persists.",
          {});
    }
  }

  Future<void> sendOtp(LoginData data) async {
    final response = await _apiService.makeRequest(
      HTTPMethod.POST,
      "/me/login",
      body: {
        "input_data": data.inputData,
        "input_format":
            data.inputType == LoginType.email ? "email" : "phone_number",
        "school_id": data.schoolIDAndName!.$1
      },
    );

    if (response.statusCode != 200) {
      throw ApiException.fromResponse(response);
    }
  }

  void logout() {
    _tokenService.removeAllTokens();
  }

  bool tokenExpired(String token) {
    return _tokenService.tokenExpiredOrInvalid(token);
  }

  Future<void> renewToken() {
    throw UnimplementedError("AUTH SERVICE RENWEW TOKEN NOT IMPLEMENTED");
  }

  Future<void> registerDevice(String token, String contactData) async {
    try {
      final response = await _apiService.makeRequest(
        HTTPMethod.POST,
        "/me/device",
        isAuthenticated: true,
        body: {
          "device_token": token,
          "logged_in_through": contactData,
          "device_type": kIsWeb ? "web" : "android"
        },
      );

      if (response.statusCode != 200) {
        throw ApiException.fromResponse(response);
      }
    } on ApiClientException catch (_) {
      rethrow;
    }
  }
}
