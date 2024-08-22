enum LoginType { email, phoneNumber }

Map<String, String> schoolData = {
  "sri-chaitanya-techno-school-hyderabad":
      "Sri Chaitanya Techno School, Hyderabad",
  "dav-public-school-delhi": "DAV Public School, Delhi",
  "holy-cross-school-mumbai": "Holy Cross School, Mumbai",
  "st-josephs-convent-school-bangalore":
      "St. Joseph's Convent School, Bangalore",
  "kendriya-vidyalaya-chanakyapuri-delhi":
      "Kendriya Vidyalaya Chanakyapuri, Delhi",
};

class UserLoginData {
  final LoginType? inputType;
  final String? inputData;
  final (String, String)? schoolIDAndName;

  UserLoginData({
    this.inputType,
    this.inputData,
    this.schoolIDAndName,
  });

  UserLoginData copyWith({
    LoginType? inputType,
    String? inputData,
    (String, String)? schoolIDAndName,
  }) {
    return UserLoginData(
      inputType: inputType ?? this.inputType,
      inputData: inputData ?? this.inputData,
      schoolIDAndName: schoolIDAndName ?? this.schoolIDAndName,
    );
  }
}
