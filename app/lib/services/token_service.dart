import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static final TokenService instance = TokenService._internal();

  factory TokenService() {
    return instance;
  }

  TokenService._internal();

  bool tokenExpired(String token) {
    final JWT data = JWT.decode(token);
    final int exp = int.parse(data.payload!["exp"]);

    if (exp >= DateTime.now().millisecondsSinceEpoch) return false;

    return true;
  }

  bool tokenValid(String token) {
    final JWT? data = JWT.tryDecode(token);

    if (data == null) return false;

    final int? exp = int.tryParse(data.payload!["exp"]);

    if (exp == null) return false;

    if (exp >= DateTime.now().millisecondsSinceEpoch) return false;

    return true;
  }

  Future<String?> getAccessToken() {
    return _secureStorage.read(key: "accessToken");
  }

  Future<void> storeAccessToken(String token) {
    return _secureStorage.write(key: "accessToken", value: token);
  }
}
