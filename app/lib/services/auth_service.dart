import 'package:app/models/login_data.dart';
import 'package:app/services/api_service.dart';
import 'package:app/services/shared_pref_service.dart';
import 'package:app/services/token_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<bool> isLoggedIn() async {
    final TokenService _tokenService = TokenService();

    String? accessToken = await _tokenService.getAccessToken();
    if (accessToken == null) return false;
    if (!_tokenService.tokenValid(accessToken)) return false;
    return true;
  }

  Future<bool> isFirstTimeLogin() async {
    return await SharedPrefService.sharedPrefs.getBool("firstTimeLogin") ??
        true;
  }

  Future<void> sendOtp(LoginData data) async {
    final response;

    try {
      response = await _apiService.makeRequest(
        HTTPMethod.POST,
        "/me/login",
        body: {
          "input_data": data.inputData,
          "input_format":
              data.inputType == LoginType.email ? "email" : "phone_number",
          "school_id": data.schoolIDAndName!.$1
        },
      );
    } on ApiClientException catch (_) {
      rethrow;
    }

    throw UnimplementedError(
        "If you got to this point, then well atleast some code worked lol ");
  }

  bool tokenExpired(String token) {
    final TokenService _tokenService = TokenService();
    return _tokenService.tokenExpired(token);
  }

  Future<void> renewToken() {
    throw UnimplementedError();
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
}
