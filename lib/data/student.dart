import 'package:krish_connect/main.dart';
import 'package:krish_connect/service/database.dart';

class Student {
  String name;
  String rollno;
  String department;
  String section;
  int semester;
  String location;
  String phoneNumber;
  bool locationPrivacy;
  bool isEmpty;

  factory Student.empty() {
    Student stu = Student();
    stu.isEmpty = true;
    return stu;
  }

  Student(
      {this.name,
      this.rollno,
      this.department,
      this.section,
      this.location,
      this.phoneNumber,
      this.locationPrivacy,
      this.semester}) {
    this.isEmpty = false;
  }
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      department: json["department"],
      name: json["name"],
      location: json["location"],
      locationPrivacy: json["locationPrivacy"],
      phoneNumber: json["phoneNumber"],
      rollno: json["rollno"],
      section: json["section"],
      semester: json["semester"],
    );
  }
  static Future<Student> create(String roll) async {
    Map<String, dynamic> json = await getIt<Database>().getStudent(roll);
    if (json == null) {
      return Student.empty();
    }
    return Student.fromJson(json);
  }

  Future<void> updateDetails(Map json) async {
    isEmpty = false;
    department = json["department"];
    name = json["name"];
    location = json["location"];
    locationPrivacy = json["locationPrivacy"];
    phoneNumber = json["phoneNumber"];
    rollno = json["rollno"];
    section = json["section"];
    semester = json["semester"];
    await getIt<Database>().updateInfo();
    return;
  }

  @override
  String toString() {
    return this.name.toString() +
        this.rollno.toString() +
        this.department.toString() +
        this.section.toString() +
        this.location.toString() +
        this.phoneNumber.toString() +
        this.locationPrivacy.toString() +
        this.semester.toString();
  }
}
