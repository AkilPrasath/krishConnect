import 'dart:async';

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

  Stream<dynamic> requestsStream(Student student) {
    String docName = student.semester.toString() +
        student.department.toUpperCase() +
        student.section.toUpperCase();
    String rollno = student.rollno;
    Stream<QuerySnapshot> mainStream =
        _firestore.collection("requests").snapshots();

    StreamController controller2 = StreamController.broadcast();
    // ignore: close_sinks
    StreamController<QuerySnapshot> controller1 =
        StreamController<QuerySnapshot>.broadcast();
    controller1.addStream(mainStream);

    var classSectionFilter = StreamTransformer.fromHandlers(
        handleData: (QuerySnapshot querySnapshot, EventSink<dynamic> sink) {
      List<Map<String, dynamic>> rollFilteredList = [];
      for (DocumentChange documentChange in querySnapshot.docChanges) {
        if (documentChange.doc.id == docName) {
          for (Map<String, dynamic> map
              in documentChange.doc.data()["requests"]) {
            if (map["rollno"] == rollno) {
              rollFilteredList.add(map);
            }
          }

          sink.add(rollFilteredList);
          break;
        }
      }
    });
    controller1.stream.transform(classSectionFilter).pipe(controller2);
    // controller2.stream.listen((result) {
    // result.docChanges.forEach((res) {
    //   if (res.type == DocumentChangeType.added) {
    //     print("added");
    //     print(res.doc.data());
    //   } else if (res.type == DocumentChangeType.modified) {
    //     print("modified");
    //     print(res.doc.data());
    //   } else if (res.type == DocumentChangeType.removed) {
    //     print("removed");
    //     print(res.doc.data());
    //   }
    // });
    //   print(result);
    // });

    return controller2.stream;
  }

  deleteRequest(Timestamp timestamp) async {
    Student student = await getIt.getAsync<Student>();
    String docName = student.semester.toString() +
        student.department.toUpperCase() +
        student.section.toUpperCase();
    String rollno = student.rollno;
    DocumentSnapshot classDocument =
        await _firestore.collection("requests").doc("$docName").get();
    List<dynamic> oldRequestList = classDocument.data()["requests"];

    oldRequestList.removeWhere((element) {
      if (element["rollno"] == rollno && element["timestamp"] == timestamp) {
        return true;
      }
      return false;
    });
    _firestore.collection("requests").doc("$docName").set({
      "requests": oldRequestList,
    });
  }

  Future<Map<String, dynamic>> getTutors() async {
    Student student = await getIt.getAsync<Student>();
    DocumentSnapshot tutorsList = await _firestore
        .collection(
            "/departments/${student.department}/semesters/${student.semester}/tutors")
        .doc("${student.section}")
        .get();
    return tutorsList.data()["tutors"];
  }

  addNewRequest(Map<String, dynamic> requestMap) async {
    Student student = await getIt.getAsync<Student>();
    String docName = student.semester.toString() +
        student.department.toUpperCase() +
        student.section.toUpperCase();
    DocumentSnapshot classDocument =
        await _firestore.collection("requests").doc("$docName").get();
    if (classDocument.exists) {
      List<dynamic> oldRequestList = classDocument.data()["requests"];
      if (oldRequestList == null) {
        oldRequestList = [];
      }
      oldRequestList.add(requestMap);
      _firestore.collection("requests").doc("$docName").set({
        "requests": oldRequestList,
      });
    } else {
      _firestore.collection("requests").doc("$docName").set({
        "requests": [requestMap],
      });
    }
  }
}
