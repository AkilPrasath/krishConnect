import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:krish_connect/data/student.dart';

class Database {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<Student> getStudent(String rollno) async {
    DocumentSnapshot studentDoc =
        await _firestore.collection("students").doc("$rollno").get();
    if (studentDoc.exists) {
      Student student = Student.fromJson(studentDoc.data());
      return student;
    } else {
      return Student.empty();
    }
  }
}
