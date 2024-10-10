import "package:uuid/uuid.dart";

enum UserType { teacher, student }

class UserModel {
  final String publicId;
  final String firstName;
  final String? middleName;
  final String lastName;
  final UserType userType;
  final List<UserContact> contacts;
  final dynamic details;

  UserModel({
    required this.publicId,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.userType,
    required this.contacts,
    required this.details,
  });
}

class UserContact {
  ContactType contactType;
  String contactData;

  UserContact({required this.contactType, required this.contactData});
}

enum ContactType { email, phoneNumber }

class TeacherDetails {
  final Classroom? classTeacherOf;
  final List<Classroom> subjectTeacherOf;
  final List<TeacherDepartment> departments;

  TeacherDetails({
    this.classTeacherOf,
    required this.subjectTeacherOf,
    required this.departments,
  });
}

class StudentDetails {
  final Classroom? classroom;

  StudentDetails({
    this.classroom,
  });
}

class TeacherDepartment {
  final String deptCode;
  final String deptName;

  TeacherDepartment({required this.deptCode, required this.deptName});
}

class Classroom {
  final String standard;
  final String division;

  Classroom({required this.standard, required this.division});
}
