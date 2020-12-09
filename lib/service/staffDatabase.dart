import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:krish_connect/data/staff.dart';
import 'package:krish_connect/main.dart';
import 'package:logger/logger.dart';

class StaffDatabase {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Logger logger = Logger();
  Future<Map<String, dynamic>> getStaff(String mailName) async {
    DocumentSnapshot staffDoc =
        await _firestore.collection("staffs").doc("$mailName").get();
    if (staffDoc.exists) {
      return staffDoc.data();
    } else {
      return null;
    }
  }

  Future<bool> checkLocationPrivacy(String staffName) async {
    DocumentSnapshot doc =
        await _firestore.collection("staffs").doc("$staffName").get();
    bool locationPrivacy = doc.data()["locationPrivacy"];
    return locationPrivacy;
  }

  Future<void> updateLocation(String position, String staffName) async {
    await _firestore.collection("staffs").doc("$staffName").update({
      "location": position,
      "time": DateTime.now(),
    });
    Logger().wtf("staff loc updated");
  }

  Future isStaffExist(String mailName) async {
    DocumentSnapshot staffDoc =
        await _firestore.collection("staffs").doc("$mailName").get();
    if (staffDoc.exists) {
      return true;
    }
    return false;
  }

  Future<void> updateDetails(
      {String name,
      String phoneNumber,
      bool locationPrivacy,
      List<Map<String, dynamic>> subjectMapList,
      Map<String, dynamic> tutorMap,
      String mail}) async {
    await _firestore.collection("staffs").doc("${mail.split("@")[0]}").set({
      "name": name,
      "phoneNumber": phoneNumber,
      "locationPrivacy": locationPrivacy,
      "subjects": subjectMapList,
      "tutor": tutorMap,
      "mail": mail,
    });

    logger.wtf(tutorMap);
    if (tutorMap != null && tutorMap.isNotEmpty) {
      logger.i(tutorMap);
      DocumentSnapshot tutorDoc = await _firestore
          .collection("departments")
          .doc("${tutorMap["department"]}")
          .collection("semesters")
          .doc("${tutorMap["semester"]}")
          .collection("tutors")
          .doc("${tutorMap["section"]}")
          .get();
      logger.wtf(tutorDoc.data());
      Map<String, dynamic> map =
          (tutorDoc.data() == null) ? {} : tutorDoc.data()["tutors"];
      map["$name"] = mail;
      await _firestore
          .collection("departments")
          .doc("${tutorMap["department"]}")
          .collection("semesters")
          .doc("${tutorMap["semester"]}")
          .collection("tutors")
          .doc("${tutorMap["section"]}")
          .update({"tutors": map});
    }
  }

  Stream<dynamic> requestsStream(Staff staff) {
    String docName = staff.tutor["semester"].toString() +
        staff.tutor["department"].toString() +
        staff.tutor["section"];
    // Logger().w(docName);
    Stream<QuerySnapshot> mainStream =
        _firestore.collection("requests").snapshots();
    StreamController controller2 = StreamController.broadcast();
    // ignore: close_sinks
    StreamController<QuerySnapshot> controller1 =
        StreamController<QuerySnapshot>.broadcast();
    controller1.addStream(mainStream);

    var classSectionFilter = StreamTransformer.fromHandlers(
        handleData: (QuerySnapshot querySnapshot, EventSink<dynamic> sink) {
      List<Map<String, dynamic>> unAttendedRequestList = [];
      for (DocumentChange documentChange in querySnapshot.docChanges) {
        if (documentChange.doc.id == docName) {
          for (Map<String, dynamic> map
              in documentChange.doc.data()["requests"]) {
            if (map["response"] == 0) {
              unAttendedRequestList.add(map);
            }
          }

          sink.add(unAttendedRequestList);
          break;
        }
      }
    });
    controller1.stream.transform(classSectionFilter).pipe(controller2);
    return controller2.stream;
  }

  Stream<dynamic> allRequestStream(Staff staff) {
    String docName = staff.tutor["semester"].toString() +
        staff.tutor["department"] +
        staff.tutor["section"];
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
            rollFilteredList.add(map);
          }
          sink.add(rollFilteredList);
          break;
        }
      }
    });
    controller1.stream.transform(classSectionFilter).pipe(controller2);

    return controller2.stream;
  }

  Future<void> setRequestResponse(
      bool response, Timestamp timestamp, String rollno) async {
    Staff staff = await getIt.getAsync<Staff>();
    DocumentSnapshot document = await _firestore
        .collection("requests")
        .doc(staff.tutor["semester"].toString() +
            staff.tutor["department"] +
            staff.tutor["section"])
        .get();
    List docs = document.data()["requests"];
    docs.forEach((element) {
      if (element["timestamp"] == timestamp && element["rollno"] == rollno) {
        response ? element["response"] = 1 : element["response"] = -1;
      }
    });
    await _firestore
        .collection("requests")
        .doc(staff.tutor["semester"].toString() +
            staff.tutor["department"] +
            staff.tutor["section"])
        .set({"requests": docs});
  }

  Future<void> postAnnouncement(Map announcementData) async {
    Staff staff = await getIt.getAsync<Staff>();
    String className = announcementData["class"].toString().split("-").join("");
    Logger().w(className);
    await _firestore.runTransaction((Transaction transaction) async {
      DocumentSnapshot classDoc = await transaction
          .get(_firestore.collection("announcements").doc("$className"));
      List announcementList = classDoc.data()["announcements"] ?? [];
      Map<String, dynamic> data = {
        "body": announcementData["body"],
        "lastData": announcementData["lastDate"],
        "name": {
          staff.mail.split("@")[0]: staff.name,
        },
        "priority": announcementData["priority"],
        "response": {},
        "timestamp": DateTime.now(),
        "type": announcementData["type"],
      };
      announcementList.add(data);
      transaction.update(
        _firestore.collection("announcements").doc("$className"),
        {"announcements": announcementList},
      );
    });
  }

  Stream getAnnouncementStream({Staff staff, dynamic subjectMap}) {
    String docName = "";
    String sem = subjectMap["semester"].toString();
    String dep = subjectMap["department"].toString();
    String sec = subjectMap["section"].toString();
    docName = sem + dep + sec;
    // logger.w(className);

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
            rollFilteredList.add(map);
          }
          rollFilteredList = rollFilteredList.reversed
              .toList(); //sorted with the newest on top
          sink.add(rollFilteredList);
          break;
        }
      }
    });
    controller1.stream.transform(classSectionFilter).pipe(controller2);

    return controller2.stream;
  }

  Future<Map<String, dynamic>> _countClassStudents(String className) async {
    int studentsCount = 0;
    Map<String, dynamic> mapData = {"count": 0, "roll-name": {}};
    QuerySnapshot querySnapshot = await _firestore.collection("students").get();
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      Map currentData = doc.data();
      String currentClassName = currentData["semester"].toString() +
          currentData["department"] +
          currentData["section"];
      if (className == currentClassName) {
        mapData["roll-name"][currentData["rollno"]] = currentData["name"];
        studentsCount += 1;
      }
    }
    mapData["count"] = studentsCount;
    return mapData;
  }

  Stream classStudentsCountStream(String className) {
    Stream<QuerySnapshot> mainStream =
        _firestore.collection("students").snapshots();

    StreamController controller2 = StreamController.broadcast();
    // ignore: close_sinks
    StreamController<QuerySnapshot> controller1 =
        StreamController<QuerySnapshot>.broadcast();
    controller1.addStream(mainStream);

    var classSectionFilter = StreamTransformer.fromHandlers(handleData:
        (QuerySnapshot querySnapshot, EventSink<dynamic> sink) async {
      Map<String, dynamic> classMap = await _countClassStudents(className);
      sink.add(classMap);
    });
    controller1.stream.transform(classSectionFilter).pipe(controller2);

    return controller2.stream;
  }

  Stream<DocumentSnapshot> responseStatStream(String className) {
    return _firestore.collection("announcements").doc("$className").snapshots();
  }

  Stream<DocumentSnapshot> getStudentStream(String rollno) {
    return _firestore.collection("students").doc(rollno).snapshots();
  }
}
