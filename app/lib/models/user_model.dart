import 'dart:convert';

import 'package:app/models/school_model.dart';

enum UserType { teacher, student }

class UserModel {
  final String publicId;
  final String firstName;
  final String? middleName;
  final String lastName;
  final UserType userType;
  final List<UserContact> contacts;
  final SchoolModel school;
  final dynamic details;

  UserModel({
    required this.publicId,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.userType,
    required this.contacts,
    required this.details,
    required this.school,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      publicId: json['public_id'],
      firstName: json['first_name'],
      middleName: json['middle_name'],
      lastName: json['last_name'],
      userType:
          json["user_type"] == "student" ? UserType.student : UserType.teacher,
      contacts: (json['contacts'] as List)
          .map((contactJson) => UserContact.fromJson(contactJson))
          .toList(),
      school: SchoolModel.fromJson(json['school']),
      details: json["user_type"] == "student"
          ? StudentDetails.fromJson(json['details'])
          : TeacherDetails.fromJson(json["details"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'public_id': publicId,
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'user_type': userType.name,
      'contacts': contacts.map((contact) => contact.toJson()).toList(),
      'details': details,
      'school': school.toJson()
    };
  }
}

class UserContact {
  ContactType contactType;
  ContactImportance contactImportance;
  String contactData;

  UserContact({
    required this.contactType,
    required this.contactData,
    required this.contactImportance,
  });

  factory UserContact.fromJson(Map<String, dynamic> json) {
    return UserContact(
      contactType: json["contact_type"] == "phone_number"
          ? ContactType.phoneNumber
          : ContactType.email,
      contactData: json['contact_data'],
      contactImportance: json["contact_importance"] == "primary"
          ? ContactImportance.primary
          : ContactImportance.secondary,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contact_type':
          contactType == ContactType.phoneNumber ? 'phone_number' : 'email',
      'contact_data': contactData,
      'contact_importance': contactImportance == ContactImportance.primary
          ? 'primary'
          : 'secondary',
    };
  }
}

enum ContactType { email, phoneNumber }

enum ContactImportance { primary, secondary }

class TeacherDetails {
  final Classroom? classTeacherOf;
  final List<Classroom> subjectTeacherOf;
  final List<TeacherDepartment> departments;

  TeacherDetails({
    this.classTeacherOf,
    required this.subjectTeacherOf,
    required this.departments,
  });

  factory TeacherDetails.fromJson(Map<String, dynamic> json) {
    return TeacherDetails(
      classTeacherOf: json['class_teacher_of'] != null
          ? Classroom.fromJson(json['class_teacher_of'])
          : null,
      subjectTeacherOf: (json['subject_teacher_of'] as List)
          .map((classroomJson) => Classroom.fromJson(classroomJson))
          .toList(),
      departments: (json['departments'] as List)
          .map((departmentJson) => TeacherDepartment.fromJson(departmentJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class_teacher_of': classTeacherOf?.toJson(),
      'subject_teacher_of':
          subjectTeacherOf.map((classroom) => classroom.toJson()).toList(),
      'departments':
          departments.map((department) => department.toJson()).toList(),
    };
  }
}

class StudentDetails {
  final Classroom? classroom;

  StudentDetails({
    this.classroom,
  });

  factory StudentDetails.fromJson(Map<String, dynamic> json) {
    return StudentDetails(
      classroom: json['classroom'] != null
          ? Classroom.fromJson(json['classroom'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'classroom': classroom?.toJson(),
    };
  }
}

class TeacherDepartment {
  final String deptCode;
  final String deptName;

  TeacherDepartment({required this.deptCode, required this.deptName});

  factory TeacherDepartment.fromJson(Map<String, dynamic> json) {
    return TeacherDepartment(
      deptCode: json['department_code'],
      deptName: json['department_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'department_code': deptCode,
      'department_name': deptName,
    };
  }
}

class Classroom {
  final String standard;
  final String division;

  Classroom({required this.standard, required this.division});

  @override
  String toString() {
    return '$standard${division.toUpperCase()}';
  }

  factory Classroom.fromJson(Map<String, dynamic> json) {
    return Classroom(
      standard: json['standard'],
      division: json['division'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'standard': standard,
      'division': division,
    };
  }
}
