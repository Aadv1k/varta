import "dart:io";

import "package:app/services/token_service.dart";
import "package:http/http.dart" as http;

enum HTTPMethod { GET, POST, DELETE }

class ApiServiceException implements Exception {
  ApiServiceException(String s);
}

class ApiService {
  static const String baseApiUrl = "http://localhost:8000/api/v1";
  final TokenService _tokenService = TokenService();

  Future<http.Response> makeRequest(HTTPMethod method, String endpoint,
      {dynamic body, bool isAuthenticated = false}) async {
    Map<String, String> headers = {};
    if (isAuthenticated) {
      String? accessToken = await _tokenService.getAccessToken();

      if (accessToken == null) {
        throw ApiServiceException(
            "Can't make an authenticated request when an access token isn't set");
      }

      // TODO: fix this lol
      // if (_tokenService.tokenExpired(accessToken)) {
      //   throw UnimplementedError("NEED TO RENEW THE TOKEN HERE LOL");
      //   //accessToken = await _tokenService.getAccessToken();
      // }

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
        "Unreachable. All HTTP methods should be handled in the HTTPMethod switch case");
  }

  Future<http.Response> get(String endpoint) async {
    return await makeRequest(HTTPMethod.GET, endpoint);
  }
}
