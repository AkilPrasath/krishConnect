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
    return controller2.stream;
  }

  Stream<dynamic> announcementsStream(Student student) {
    String docName = student.semester.toString() +
        student.department.toUpperCase() +
        student.section.toUpperCase();
    String rollno = student.rollno;
    Stream<QuerySnapshot> mainStream =
        _firestore.collection("announcements").snapshots();

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
              in documentChange.doc.data()["announcements"]) {
            if (map["response"]["$rollno"] == null) {
              rollFilteredList.add(map);
            }
          }
          sink.add(rollFilteredList);
          break;
        }
      }
    });
    controller1.stream.transform(classSectionFilter).pipe(controller2);

    return controller2.stream;
  }

  deleteRequest(Timestamp timestamp) async {
    Student student = await getIt.getAsync<Student>();
    String docName = student.semester.toString() +
        student.department.toUpperCase() +
        student.section.toUpperCase();
    String rollno = student.rollno;
    //start transaction
    _firestore.runTransaction((Transaction transaction) async {
      DocumentReference doc = _firestore.collection("requests").doc("$docName");
      return transaction
          .get(doc)
          .then((DocumentSnapshot documentSnapshot) async {
        List<dynamic> oldRequestList = documentSnapshot.data()["requests"];
        oldRequestList.removeWhere((element) {
          if (element["rollno"] == rollno &&
              element["timestamp"] == timestamp) {
            return true;
          }
          return false;
        });
        await _firestore.collection("requests").doc("$docName").update({
          "requests": oldRequestList,
        });
      });
    });

    //end transaction
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
    //  await _firestore.runTransaction((transaction) async{
    //    return await transaction
    //  });
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

  Future<void> setAnnouncementResponse(
      dynamic timestamp, dynamic name, bool response) async {
    Student student = await getIt.getAsync<Student>();
    String docName = student.semester.toString() +
        student.department.toUpperCase() +
        student.section.toUpperCase();
    String rollno = student.rollno;
    await _firestore.runTransaction((transaction) async {
      return await transaction
          .get(_firestore.collection("announcements").doc("$docName"))
          .then((DocumentSnapshot doc) async {
        Map<String, dynamic> announce;
        List<dynamic> announcementList = doc.data()["announcements"];
        announcementList.forEach((element) {
          if (element["timestamp"] == timestamp &&
              element["name"].keys.toList()[0] == name) {
            element["response"][student.rollno] = response;
          }
        });
        await _firestore
            .collection("announcements")
            .doc("$docName")
            .set({"announcements": announcementList});
      });
    });
  }
}
