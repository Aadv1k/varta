import 'dart:convert';

import 'package:http/http.dart';

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

class ApiException implements Exception {
  final Map<String, String>? errors;
  final String message;
  ApiException(this.message, this.errors);

  static ApiException fromResponse(Response response) {
    final dynamic errorResponse = jsonEncode(response.body);
    final Map<String, String> errorResponseDetails = {
      for (final errorField in errorResponse["errors"])
        errorField["field"]: errorField["error"]
    };
    return ApiException(errorResponse["message"], errorResponseDetails);
  }
}
