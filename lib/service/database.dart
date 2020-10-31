import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:krish_connect/data/student.dart';
import 'package:krish_connect/main.dart';
import 'package:krish_connect/service/authentication.dart';

class Database {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<Map<String, dynamic>> getStudent(String rollno) async {
    DocumentSnapshot studentDoc =
        await _firestore.collection("students").doc("$rollno").get();
    if (studentDoc.exists) {
      return studentDoc.data();
      // Student student = Student.fromJson(studentDoc.data());
      // return student;
    } else {
      return null;
    }
  }

  Future<void> updateInfo() async {
    String rollno = getIt<Authentication>().currentUser.email.substring(0, 9);
    Student student = await getIt.getAsync<Student>();
    await _firestore.collection("students").doc("$rollno").set({
      "department": student.department,
      "name": student.name,
      "location": student.location,
      "locationPrivacy": student.locationPrivacy,
      "phoneNumber": student.phoneNumber,
      "rollno": student.rollno,
      "section": student.section,
      "semester": student.semester,
    });
  }
}
