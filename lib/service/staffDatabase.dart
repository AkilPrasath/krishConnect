import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:krish_connect/data/staff.dart';
import 'package:krish_connect/main.dart';
import 'package:logger/logger.dart';

class StaffDatabase {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<Map<String, dynamic>> getStaff(String mailName) async {
    print(" akilakil $mailName");
    DocumentSnapshot staffDoc =
        await _firestore.collection("staffs").doc("$mailName").get();
    if (staffDoc.exists) {
      return staffDoc.data();
    } else {
      return null;
    }
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
    Logger log = Logger();
    log.wtf(tutorMap);
    if (tutorMap != null) {
      DocumentSnapshot tutorDoc = await _firestore
          .collection("departments")
          .doc("${tutorMap["department"]}")
          .collection("semesters")
          .doc("${tutorMap["semester"]}")
          .collection("tutors")
          .doc("${tutorMap["section"]}")
          .get();
      log.wtf(tutorDoc.data());
      Map<String, dynamic> map = tutorDoc.data()["tutors"];
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
    String docName=staff.tutor["semester"].toString()+staff.tutor["department"]+staff.tutor["section"];
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
}
