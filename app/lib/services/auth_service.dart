import 'package:app/services/token_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final _authServiceInstance = AuthService._internal();

  AuthService._internal();

  factory AuthService() {
    return _authServiceInstance;
  }

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static late final SharedPreferences sharedPrefs;
  final TokenService _tokenService = TokenService();

  Future initSharedPrefs() async {
    sharedPrefs = await SharedPreferences.getInstance();
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

  bool tokenExpired(String token) {
    return _tokenService.tokenExpired(token);
  }

  Future renewToken() {
    throw UnimplementedError();
  }

  bool isFirstTimeLogin() {
    bool? cond = sharedPrefs.getBool("firstTimeLogin");
    if (cond == null) return true;
    return false;
  }
}
