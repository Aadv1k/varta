import "package:uuid/uuid.dart";

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

enum ContactType { email, phoneNumber }

class UserContact {
  ContactType contactType;
  String contactData;

  UserContact({required this.contactType, required this.contactData});
}

class StudentModel {
  final String publicId;
  final String firstName;
  final String? middleName;
  final String lastName;

  final Classroom? classroom;

  final List<UserContact> contacts;

  StudentModel({
    required this.publicId,
    required this.contacts,
    this.classroom,
    required this.firstName,
    this.middleName,
    required this.lastName,
  });
}

class TeacherModel {
  final String publicId;
  final String firstName;
  final String? middleName;
  final String lastName;

  final Classroom? classTeacherOf;
  final List<Classroom> subjectTeacherOf;
  final List<TeacherDepartment> departments;

  final List<UserContact> contacts;

  TeacherModel(
      {required this.publicId,
      required this.contacts,
      required this.firstName,
      this.middleName,
      required this.lastName,
      this.classTeacherOf,
      required this.subjectTeacherOf,
      required this.departments});
}

final List<TeacherModel> mockTeacherData = [
  TeacherModel(
    publicId: const Uuid().v4(),
    firstName: 'Ravi',
    lastName: 'Patel',
    classTeacherOf: Classroom(standard: '10', division: 'A'),
    subjectTeacherOf: [
      Classroom(standard: '10', division: 'A'),
      Classroom(standard: '9', division: 'B'),
    ],
    departments: [
      TeacherDepartment(deptCode: 'MAT', deptName: 'Mathematics'),
      TeacherDepartment(deptCode: 'CS', deptName: 'Computer Science'),
    ],
    contacts: [
      UserContact(
          contactType: ContactType.email, contactData: 'ravi.patel@school.com'),
      UserContact(
          contactType: ContactType.phoneNumber, contactData: '9876543210'),
    ],
  ),
  TeacherModel(
    publicId: const Uuid().v4(),
    firstName: 'Suman',
    lastName: 'Chopra',
    classTeacherOf: Classroom(standard: '9', division: 'B'),
    subjectTeacherOf: [
      Classroom(standard: '9', division: 'B'),
      Classroom(standard: '8', division: 'C'),
    ],
    departments: [
      TeacherDepartment(deptCode: 'SCI', deptName: 'Science'),
      TeacherDepartment(deptCode: 'BIO', deptName: 'Biology'),
    ],
    contacts: [
      UserContact(
          contactType: ContactType.email,
          contactData: 'suman.chopra@school.com'),
      UserContact(
          contactType: ContactType.phoneNumber, contactData: '9876543211'),
    ],
  ),
  TeacherModel(
    publicId: const Uuid().v4(),
    firstName: 'Ananya',
    lastName: 'Mehra',
    classTeacherOf: null,
    subjectTeacherOf: [
      Classroom(standard: '10', division: 'B'),
      Classroom(standard: '11', division: 'A'),
    ],
    departments: [
      TeacherDepartment(deptCode: 'HIS', deptName: 'History'),
      TeacherDepartment(deptCode: 'SOC', deptName: 'Social Studies'),
    ],
    contacts: [
      UserContact(
          contactType: ContactType.email,
          contactData: 'ananya.mehr@school.com'),
      UserContact(
          contactType: ContactType.phoneNumber, contactData: '9876543212'),
    ],
  ),
  TeacherModel(
    publicId: const Uuid().v4(),
    firstName: 'Nikhil',
    lastName: 'Reddy',
    classTeacherOf: Classroom(standard: '8', division: 'C'),
    subjectTeacherOf: [
      Classroom(standard: '8', division: 'C'),
      Classroom(standard: '7', division: 'A'),
    ],
    departments: [
      TeacherDepartment(deptCode: 'ENG', deptName: 'English'),
      TeacherDepartment(deptCode: 'HIN', deptName: 'Hindi'),
    ],
    contacts: [
      UserContact(
          contactType: ContactType.email,
          contactData: 'nikhil.reddy@school.com'),
      UserContact(
          contactType: ContactType.phoneNumber, contactData: '9876543213'),
    ],
  ),
  TeacherModel(
    publicId: const Uuid().v4(),
    firstName: 'Aarti',
    lastName: 'Singh',
    classTeacherOf: null,
    subjectTeacherOf: [
      Classroom(standard: '12', division: 'A'),
      Classroom(standard: '11', division: 'B'),
    ],
    departments: [
      TeacherDepartment(deptCode: 'PHY', deptName: 'Physics'),
      TeacherDepartment(deptCode: 'CS', deptName: 'Computer Science'),
    ],
    contacts: [
      UserContact(
          contactType: ContactType.email,
          contactData: 'aarti.singh@school.com'),
      UserContact(
          contactType: ContactType.phoneNumber, contactData: '9876543214'),
    ],
  ),
  TeacherModel(
    publicId: const Uuid().v4(),
    firstName: 'Vikram',
    lastName: 'Jain',
    classTeacherOf: Classroom(standard: '7', division: 'A'),
    subjectTeacherOf: [
      Classroom(standard: '7', division: 'A'),
      Classroom(standard: '6', division: 'B'),
    ],
    departments: [
      TeacherDepartment(deptCode: 'MAT', deptName: 'Mathematics'),
      TeacherDepartment(deptCode: 'SST', deptName: 'Social Studies'),
    ],
    contacts: [
      UserContact(
          contactType: ContactType.email,
          contactData: 'vikram.jain@school.com'),
      UserContact(
          contactType: ContactType.phoneNumber, contactData: '9876543215'),
    ],
  ),
  TeacherModel(
    publicId: const Uuid().v4(),
    firstName: 'Meera',
    lastName: 'Verma',
    classTeacherOf: null,
    subjectTeacherOf: [
      Classroom(standard: '11', division: 'B'),
      Classroom(standard: '12', division: 'C'),
    ],
    departments: [
      TeacherDepartment(deptCode: 'CHE', deptName: 'Chemistry'),
      TeacherDepartment(deptCode: 'BIO', deptName: 'Biology'),
    ],
    contacts: [
      UserContact(
          contactType: ContactType.email,
          contactData: 'meera.verma@school.com'),
      UserContact(
          contactType: ContactType.phoneNumber, contactData: '9876543216'),
    ],
  ),
  TeacherModel(
    publicId: const Uuid().v4(),
    firstName: 'Rajesh',
    lastName: 'Deshmukh',
    classTeacherOf: Classroom(standard: '6', division: 'B'),
    subjectTeacherOf: [
      Classroom(standard: '6', division: 'B'),
      Classroom(standard: '7', division: 'B'),
    ],
    departments: [
      TeacherDepartment(deptCode: 'BIO', deptName: 'Biology'),
      TeacherDepartment(deptCode: 'ENG', deptName: 'English'),
    ],
    contacts: [
      UserContact(
          contactType: ContactType.email,
          contactData: 'rajesh.deshmukh@school.com'),
      UserContact(
          contactType: ContactType.phoneNumber, contactData: '9876543217'),
    ],
  ),
  TeacherModel(
    publicId: const Uuid().v4(),
    firstName: 'Pooja',
    lastName: 'Kapoor',
    classTeacherOf: Classroom(standard: '8', division: 'A'),
    subjectTeacherOf: [
      Classroom(standard: '8', division: 'A'),
      Classroom(standard: '7', division: 'C'),
    ],
    departments: [
      TeacherDepartment(deptCode: 'SST', deptName: 'Social Studies'),
      TeacherDepartment(deptCode: 'HIS', deptName: 'History'),
    ],
    contacts: [
      UserContact(
          contactType: ContactType.email,
          contactData: 'pooja.kapoor@school.com'),
      UserContact(
          contactType: ContactType.phoneNumber, contactData: '9876543218'),
    ],
  ),
];
