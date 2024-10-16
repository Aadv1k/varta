import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SimpleCacheServiceData {
  final int cachedAt;
  final String data;

  SimpleCacheServiceData(this.cachedAt, this.data);

  String toJsonString() {
    return jsonEncode({"cachedAt": cachedAt, "data": data});
  }

  static SimpleCacheServiceData fromJsonString(String value) {
    final parsedData = jsonDecode(value);
    final cachedAt = parsedData["cachedAt"] as int;
    final data = parsedData["data"] as String;
    return SimpleCacheServiceData(cachedAt, data);
  }
}

class SimpleCacheService {
  final SharedPreferencesAsync _sharedPref = SharedPreferencesAsync();

  Future<void> store(String key, String data, { int? cachedAt }) {
    final value =
        SimpleCacheServiceData(
				cachedAt ?? DateTime.now().millisecondsSinceEpoch, data).toJsonString();
    return _sharedPref.setString(key, value);
  }

  Future<void> delete(String key) {
    return _sharedPref.remove(key);
  }

  Future<SimpleCacheServiceData?> fetchOrNull(String key,
      {Duration? exp}) async {
    String? data;
    try {
      data = await _sharedPref.getString(key);
    } on TypeError catch (_) {
      _sharedPref.remove(key);
      return null;
    }
    if (data == null) return null;
    final parsedData = SimpleCacheServiceData.fromJsonString(data);

    if (exp == null) return parsedData;

    if (DateTime.now().millisecondsSinceEpoch >=
        parsedData.cachedAt + exp.inMilliseconds) return null;

    return parsedData;
  }
}
