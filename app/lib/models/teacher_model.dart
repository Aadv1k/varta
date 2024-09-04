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

class TeacherModel {
  final String firstName;
  final String lastName;
  final Classroom? classTeacherOf;
  final List<Classroom> subjectTeacherOf;
  final List<TeacherDepartment> departments;

  TeacherModel(
      {required this.firstName,
      required this.lastName,
      this.classTeacherOf,
      required this.subjectTeacherOf,
      required this.departments});
}

final List<TeacherModel> mockTeacherData = [
  TeacherModel(
    firstName: 'Amit',
    lastName: 'Sharma',
    classTeacherOf: Classroom(standard: '10', division: 'A'),
    subjectTeacherOf: [
      Classroom(standard: '10', division: 'A'),
      Classroom(standard: '9', division: 'B'),
    ],
    departments: [
      TeacherDepartment(deptCode: 'MAT', deptName: 'Mathematics'),
      TeacherDepartment(deptCode: 'CS', deptName: 'Computer Science'),
    ],
  ),
  TeacherModel(
    firstName: 'Sneha',
    lastName: 'Patel',
    classTeacherOf: Classroom(standard: '9', division: 'B'),
    subjectTeacherOf: [
      Classroom(standard: '9', division: 'B'),
      Classroom(standard: '8', division: 'C'),
    ],
    departments: [
      TeacherDepartment(deptCode: 'SCI', deptName: 'Science'),
      TeacherDepartment(deptCode: 'BIO', deptName: 'Biology'),
    ],
  ),
  TeacherModel(
    firstName: 'Ravi',
    lastName: 'Kumar',
    classTeacherOf: null,
    subjectTeacherOf: [
      Classroom(standard: '10', division: 'B'),
      Classroom(standard: '11', division: 'A'),
    ],
    departments: [
      TeacherDepartment(deptCode: 'HIS', deptName: 'History'),
      TeacherDepartment(deptCode: 'SOC', deptName: 'Social Studies'),
    ],
  ),
  TeacherModel(
    firstName: 'Meera',
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
  ),
  TeacherModel(
    firstName: 'Suresh',
    lastName: 'Verma',
    classTeacherOf: null,
    subjectTeacherOf: [
      Classroom(standard: '12', division: 'A'),
      Classroom(standard: '11', division: 'B'),
    ],
    departments: [
      TeacherDepartment(deptCode: 'PHY', deptName: 'Physics'),
      TeacherDepartment(deptCode: 'CS', deptName: 'Computer Science'),
    ],
  ),
  TeacherModel(
    firstName: 'Priya',
    lastName: 'Singh',
    classTeacherOf: Classroom(standard: '7', division: 'A'),
    subjectTeacherOf: [
      Classroom(standard: '7', division: 'A'),
      Classroom(standard: '6', division: 'B'),
    ],
    departments: [
      TeacherDepartment(deptCode: 'MAT', deptName: 'Mathematics'),
      TeacherDepartment(deptCode: 'SST', deptName: 'Social Studies'),
    ],
  ),
  TeacherModel(
    firstName: 'Anil',
    lastName: 'Kumar',
    classTeacherOf: null,
    subjectTeacherOf: [
      Classroom(standard: '11', division: 'B'),
      Classroom(standard: '12', division: 'C'),
    ],
    departments: [
      TeacherDepartment(deptCode: 'CHE', deptName: 'Chemistry'),
      TeacherDepartment(deptCode: 'BIO', deptName: 'Biology'),
    ],
  ),
  TeacherModel(
    firstName: 'Pooja',
    lastName: 'Nair',
    classTeacherOf: Classroom(standard: '6', division: 'B'),
    subjectTeacherOf: [
      Classroom(standard: '6', division: 'B'),
      Classroom(standard: '7', division: 'B'),
    ],
    departments: [
      TeacherDepartment(deptCode: 'BIO', deptName: 'Biology'),
      TeacherDepartment(deptCode: 'ENG', deptName: 'English'),
    ],
  ),
  TeacherModel(
    firstName: 'Kiran',
    lastName: 'Desai',
    classTeacherOf: null,
    subjectTeacherOf: [
      Classroom(standard: '10', division: 'C'),
      Classroom(standard: '9', division: 'A'),
    ],
    departments: [
      TeacherDepartment(deptCode: 'SST', deptName: 'Social Studies'),
      TeacherDepartment(deptCode: 'HIS', deptName: 'History'),
    ],
  ),
  TeacherModel(
    firstName: 'Ritika',
    lastName: 'Sharma',
    classTeacherOf: Classroom(standard: '9', division: 'A'),
    subjectTeacherOf: [
      Classroom(standard: '9', division: 'A'),
      Classroom(standard: '8', division: 'A'),
    ],
    departments: [
      TeacherDepartment(deptCode: 'HIN', deptName: 'Hindi'),
      TeacherDepartment(deptCode: 'ENG', deptName: 'English'),
    ],
  ),
  TeacherModel(
    firstName: 'Vikram',
    lastName: 'Jain',
    classTeacherOf: null,
    subjectTeacherOf: [
      Classroom(standard: '11', division: 'A'),
      Classroom(standard: '12', division: 'B'),
    ],
    departments: [
      TeacherDepartment(deptCode: 'CS', deptName: 'Computer Science'),
      TeacherDepartment(deptCode: 'MAT', deptName: 'Mathematics'),
    ],
  ),
  TeacherModel(
    firstName: 'Nisha',
    lastName: 'Gupta',
    classTeacherOf: Classroom(standard: '8', division: 'A'),
    subjectTeacherOf: [
      Classroom(standard: '8', division: 'A'),
      Classroom(standard: '7', division: 'B'),
    ],
    departments: [
      TeacherDepartment(deptCode: 'ENG', deptName: 'English'),
      TeacherDepartment(deptCode: 'SST', deptName: 'Social Studies'),
    ],
  ),
  TeacherModel(
    firstName: 'Rajesh',
    lastName: 'Soni',
    classTeacherOf: null,
    subjectTeacherOf: [
      Classroom(standard: '12', division: 'B'),
      Classroom(standard: '11', division: 'C'),
    ],
    departments: [
      TeacherDepartment(deptCode: 'ECO', deptName: 'Economics'),
      TeacherDepartment(deptCode: 'PHY', deptName: 'Physics'),
    ],
  ),
];
