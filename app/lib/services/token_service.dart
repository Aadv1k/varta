import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static const FlutterSecureStorage secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static SharedPreferencesAsync sharedPrefs = SharedPreferencesAsync();

  static final TokenService instance = TokenService._internal();

  factory TokenService() {
    return instance;
  }

  TokenService._internal();

  bool tokenExpiredOrInvalid(String token) {
    final JWT? data = JWT.tryDecode(token);

    if (data == null) return true;

    final exp = data.payload["exp"];
    if (exp == null || exp is! int) {
      return true;
    }

    return (exp >= DateTime.now().millisecondsSinceEpoch);
  }

  Future<String?> getAccessToken() async {
    if (kIsWeb) {
      return sharedPrefs.getString("accessToken");
    }

    return secureStorage.read(key: "accessToken");
  }

  Future<void> storeAccessToken(String token) {
    if (kIsWeb) {
      return sharedPrefs.setString("accessToken", token);
    }
    return secureStorage.write(key: "accessToken", value: token);
  }

  Future<String?> getRefreshToken() {
    if (kIsWeb) {
      return sharedPrefs.getString("refreshToken");
    }
    return secureStorage.read(key: "refreshToken");
  }

  void removeAllTokens() async {
    if (kIsWeb) {
      sharedPrefs.remove("refreshToken");
      sharedPrefs.remove("accessToken");
    }
    secureStorage.delete(key: "refreshToken");
    secureStorage.delete(key: "accessToken");
  }

  Future<void> storeRefreshToken(String token) {
    if (kIsWeb) {
      return sharedPrefs.setString("refreshToken", token);
    }
    return secureStorage.write(key: "refreshToken", value: token);
  }
}
