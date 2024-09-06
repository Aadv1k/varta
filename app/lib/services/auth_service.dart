import 'package:app/common/exceptions.dart';
import 'package:app/models/login_data.dart';
import 'package:app/services/api_service.dart';
import 'package:app/services/shared_pref_service.dart';
import 'package:app/services/token_service.dart';
import 'package:http/http.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final TokenService _tokenService = TokenService();

  Future<bool> isLoggedIn() async {
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
    Response response;

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

      if (response.statusCode != 200) {
        throw ApiException.fromResponse(response);
      }
    } on ApiClientException catch (_) {
      rethrow;
    }

    throw UnimplementedError(
        "If you got to this point, then well atleast some code worked lol ");
  }

  bool tokenExpired(String token) {
    return _tokenService.tokenExpired(token);
  }

  Future<void> renewToken() {
    throw UnimplementedError();
  }
}
