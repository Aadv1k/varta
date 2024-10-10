import 'package:app/models/user_model.dart';
import 'package:app/services/api_service.dart';
import 'package:app/services/shared_pref_service.dart';

class UserRepo {
  final SharedPrefService _sharedPref = SharedPrefService();
  final ApiService _apiService = ApiService();

  UserRepo();

  Future<List<UserModel>> getTeachers() async {
    return [];
  }
}
