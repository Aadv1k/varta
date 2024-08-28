import 'package:app/models/login_data.dart';
import 'package:app/services/api_service.dart';
import 'package:app/services/shared_pref_service.dart';
import 'package:app/services/token_service.dart';

class AuthService {
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
    final ApiService _apiService = ApiService();

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
      throw ApiException('Failed to send OTP');
    }
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
