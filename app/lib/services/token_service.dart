import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

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

  Future<String?> getAccessToken() {
    return _secureStorage.read(key: "accessToken");
  }

  Future<void> storeAccessToken(String token) {
    return _secureStorage.write(key: "accessToken", value: token);
  }

  Future<String?> getRefreshToken() {
    return _secureStorage.read(key: "refreshToken");
  }

  Future<void> storeRefreshToken(String token) {
    return _secureStorage.write(key: "refreshToken", value: token);
  }
}
