class SchoolModel {
  final int schoolId;
  final String schoolName;
  final String schoolAddress;
  final String schoolContactNo;
  final String schoolEmail;

  SchoolModel({
    required this.schoolId,
    required this.schoolName,
    required this.schoolAddress,
    required this.schoolContactNo,
    required this.schoolEmail,
  });

  factory SchoolModel.fromJson(dynamic json) {
    return SchoolModel(
      schoolId: json['id'] as int,
      schoolName: json['name'] as String,
      schoolAddress: json['address'] as String,
      schoolContactNo: json['phone_number'] as String,
      schoolEmail: json['email'] as String,
    );
  }

  SchoolModel copyWith({
    int? schoolId,
    String? schoolName,
    String? schoolAddress,
    String? schoolContactNo,
    String? schoolEmail,
  }) {
    return SchoolModel(
      schoolId: schoolId ?? this.schoolId,
      schoolName: schoolName ?? this.schoolName,
      schoolAddress: schoolAddress ?? this.schoolAddress,
      schoolContactNo: schoolContactNo ?? this.schoolContactNo,
      schoolEmail: schoolEmail ?? this.schoolEmail,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SchoolModel && other.schoolId == schoolId;
  }

  @override
  int get hashCode => schoolId.hashCode;

  @override
  String toString() {
    return 'SchoolModel(id: $schoolId, name: $schoolName, address: $schoolAddress, contactNo: $schoolContactNo, email: $schoolEmail)';
  }

  /// Converts the [SchoolModel] instance to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'id': schoolId,
      'name': schoolName,
      'address': schoolAddress,
      'phone_number': schoolContactNo,
      'email': schoolEmail,
    };
  }
}
