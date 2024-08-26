import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class TokenService {
  bool tokenValid(String token) {
    final JWT? data = JWT.tryDecode(token);

    if (data == null) return false;

    final int? exp = int.tryParse(data.payload!["exp"]);

    if (exp == null) return false;

    if (exp >= DateTime.now().millisecondsSinceEpoch) return false;

    return true;
  }
}
