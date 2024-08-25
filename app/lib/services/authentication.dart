import 'package:app/models/user.dart';
import 'package:app/services/common.dart';

class UserAuthenticationService {
  final ApiService _apiService = ApiService();

  Future<dynamic> sendOTP(UserLoginData data) async {
    return _apiService.fetch(ApiEndpoint.userLogin, body: {
      "input_format":
          data.inputType == LoginType.email ? "email" : "phone_number",
      "input_data": data.inputData,
      "school_id": data.schoolIDAndName!.$1
    });
  }

  Future<dynamic> verifyOTPAndStore(UserLoginData data, String otp) async {
    final response = await _apiService.fetch(ApiEndpoint.userVerify, body: {
      "input_data": data.inputData,
      "school_id": data.schoolIDAndName!.$1,
      "otp": otp,
    });

    await _apiService.storeTokens(
        response["access_token"], response["refresh_token"]);

    return response;
  }

  Future<dynamic> refresh() async {
    (String?, String?) tokenPair = await _apiService.getTokens();

    final response = await _apiService
        .fetch(ApiEndpoint.userRefresh, body: {"refresh_token": tokenPair.$1});

    _apiService.storeTokens(
        response["access_token"] as String, tokenPair.$1 as String);

    return response;
  }
}
