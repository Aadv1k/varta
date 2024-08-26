enum LoginType { email, phoneNumber }

class LoginData {
  final LoginType? inputType;
  final String? inputData;
  final (String, String)? schoolIDAndName;

  LoginData({
    this.inputType,
    this.inputData,
    this.schoolIDAndName,
  });

  LoginData copyWith({
    LoginType? inputType,
    String? inputData,
    (String, String)? schoolIDAndName,
  }) {
    return LoginData(
      inputType: inputType ?? this.inputType,
      inputData: inputData ?? this.inputData,
      schoolIDAndName: schoolIDAndName ?? this.schoolIDAndName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LoginData) return false;
    return other.inputType == inputType &&
        other.inputData == inputData &&
        other.schoolIDAndName == schoolIDAndName;
  }

  @override
  int get hashCode =>
      inputType.hashCode ^ inputData.hashCode ^ schoolIDAndName.hashCode;
}
