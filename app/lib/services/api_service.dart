import "dart:io";

import "package:app/services/auth_service.dart";
import "package:http/http.dart" as http;

enum HTTPMethod { GET, POST, DELETE }

class ApiServiceException implements Exception {
  ApiServiceException(String s);
}

class ApiService {
  static const String baseApiUrl = "http://localhost:8000/api/v1";
  final AuthService _authService = AuthService();

  Future<http.Response> _makeRequest(HTTPMethod method, String endpoint,
      {dynamic body, bool isAuthenticated = false}) async {
    Map<String, String> headers = {};
    if (isAuthenticated) {
      String? accessToken = await _authService.getAccessToken();

      if (accessToken == null) {
        throw ApiServiceException(
            "Can't make an authenticated request when an access token isn't set");
      }

      if (_authService.tokenExpired(accessToken)) {
        _authService.renewToken();
        accessToken = await _authService.getAccessToken();
      }

      headers[HttpHeaders.authorizationHeader] = "Bearer $accessToken";
    }

    try {
      switch (method) {
        case HTTPMethod.GET:
          return http.get(Uri.parse("$baseApiUrl$endpoint"), headers: headers);
        case HTTPMethod.POST:
          return http.post(Uri.parse("$baseApiUrl$endpoint"),
              body: body, headers: headers);
        case HTTPMethod.DELETE:
        // TODO: Handle this case.
      }
    } on SocketException catch (e) {
      throw ApiServiceException(e.message);
    }

    throw UnsupportedError(
        "Unreacbale. All HTTP methods should be handled in the HTTPMethod switch case");
  }

  Future<http.Response> get(String endpoint) async {
    return await _makeRequest(HTTPMethod.GET, endpoint);
  }
}
