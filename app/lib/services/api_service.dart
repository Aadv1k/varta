import "dart:io";
import "package:app/services/token_service.dart";
import "package:http/http.dart" as http;

enum HTTPMethod { GET, POST, DELETE }

class ApiServiceException implements Exception {
  final String message;
  ApiServiceException(this.message);

  @override
  String toString() => "ApiServiceException: $message";
}

class ApiClientException implements Exception {
  final String message;
  ApiClientException(this.message);

  @override
  String toString() => "ApiClientException: $message";
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
            "Can't make an authenticated request when an access token isn't set. This is due to invalid call");
      }

      // TODO: handle token renewal
      // if (_tokenService.tokenExpired(accessToken)) {
      //   throw ApiServiceException("Token has expired. Implement token renewal.");
      //   //accessToken = await _tokenService.getAccessToken();
      // }

      headers[HttpHeaders.authorizationHeader] = "Bearer $accessToken";
    }

    try {
      switch (method) {
        case HTTPMethod.GET:
          return await http.get(Uri.parse("$baseApiUrl$endpoint"),
              headers: headers);
        case HTTPMethod.POST:
          return await http.post(Uri.parse("$baseApiUrl$endpoint"),
              body: body, headers: headers);
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
      throw ApiClientException("Something went wrong. Please try again.");
    }
  }
}
