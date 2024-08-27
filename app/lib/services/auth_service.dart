import 'package:app/models/login_data.dart';
import 'package:app/services/api_service.dart';
import 'package:app/services/token_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final _authService = AuthService._internal();

  factory AuthService() {
    return _authService;
  }

  AuthService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final TokenService _tokenService = TokenService();
  final ApiService _apiService = ApiService();

  SharedPreferencesAsync? sharedPrefs;

  Future initSharedPrefs() async {
    try {
      sharedPrefs = SharedPreferencesAsync();
    } catch (exc) {
      throw AssertionError("SharedPreferences chould not be initialized: $exc");
    }
  }

  Future<bool> isLoggedIn() async {
    String? accessToken = await _secureStorage.read(key: "accessToken");
    if (accessToken == null) return false;

    if (!_tokenService.tokenValid(accessToken)) return false;

    return true;
  }

  Future<String?> getAccessToken() {
    return _secureStorage.read(key: "accessToken");
  }

  Future sendOtp(LoginData data) async {
    final response =
        await _apiService.makeRequest(HTTPMethod.POST, "/me/login", body: {
      "input_data": data.inputData,
      "input_format":
          data.inputType == LoginType.email ? "email" : "phone_number",
      "school_id": data.schoolIDAndName!.$1
    });

    if (response.statusCode != 200) {
      // THROW AN ApiException here
    }
  }

  bool tokenExpired(String token) {
    return _tokenService.tokenExpired(token);
  }

  Future renewToken() {
    throw UnimplementedError();
  }

  bool isFirstTimeLogin() {
    bool? cond = sharedPrefs!.getBool("firstTimeLogin");
    if (cond == null) return true;
    return false;
  }
}
