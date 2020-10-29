import 'package:krish_connect/data/enums.dart';
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
    Student student = await getIt<Database>().getStudent(roll);
    return student;
  }

  @override
  String toString() {
    // TODO: implement toString
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
