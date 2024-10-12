import "dart:convert";
import "dart:io";
import "package:app/common/exceptions.dart";
import "package:app/services/token_service.dart";
import "package:flutter/material.dart";
import "package:http/http.dart" as http;

enum HTTPMethod { GET, POST, DELETE }

class ApiService {
  static const String baseApiUrl = "http://localhost:8000/api/v1";
  final TokenService _tokenService = TokenService();

  Future<http.Response> makeRequest(HTTPMethod method, String endpoint,
      {dynamic body, bool isAuthenticated = false}) async {
    Map<String, String> headers = {"Content-Type": "application/json"};
    if (isAuthenticated) {
      String? accessToken = await _tokenService.getAccessToken();

      if (accessToken == null ||
          _tokenService.tokenExpiredOrInvalid(accessToken)) {
        debugPrint(
            "TODO: handle renewing the access token right here. Only throw this exception when the referesh token is expired as well");
        throw ApiTokenExpiredException();
      }

      headers[HttpHeaders.authorizationHeader] = "Bearer $accessToken";
    }

    try {
      switch (method) {
        case HTTPMethod.GET:
          return await http.get(Uri.parse("$baseApiUrl$endpoint"),
              headers: headers);
        case HTTPMethod.POST:
          return await http.post(Uri.parse("$baseApiUrl$endpoint"),
              body: jsonEncode(body), headers: headers);
        case HTTPMethod.DELETE:
          // TODO: Implement DELETE request handling
          throw ApiServiceException("DELETE method is not yet implemented.");
      }
    } on SocketException catch (_) {
      throw ApiClientException(
          "We couldn't connect to the server. Please check your internet connection and try again.");
    } on HttpException catch (_) {
      throw ApiClientException(
          "We couldn't reach the server. Please try again later.");
    } on FormatException catch (_) {
      throw ApiClientException(
          "We received an unexpected response from the server.");
    } on http.ClientException catch (_) {
      throw ApiClientException(
          "An error occurred while processing your request. Please try again.");
    } catch (e) {
      debugPrint(e.toString());
      throw ApiClientException("Something went wrong. Please try again.");
    }
  }
}
