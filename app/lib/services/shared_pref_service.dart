import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  static final SharedPrefService _sharedPrefServiceInstance =
      SharedPrefService._internal();

  final SharedPreferencesAsync _sharedPrefs = SharedPreferencesAsync();

  void set(String key, dynamic data) {}

  void get(String key) {}

  factory SharedPrefService() {
    return _sharedPrefServiceInstance;
  }

  SharedPrefService._internal();
}
