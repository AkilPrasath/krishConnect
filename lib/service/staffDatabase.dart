import 'package:cloud_firestore/cloud_firestore.dart';

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
  }
}
