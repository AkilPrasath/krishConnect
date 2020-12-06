import 'package:krish_connect/main.dart';
import 'package:krish_connect/service/staffDatabase.dart';
import 'package:logger/logger.dart';

class Staff {
  String name;
  String mail;
  bool locationPrivacy;
  String location;
  String phoneNumber;

  /// list of maps in this format {"semester":1,"department":CSE,"section":A,"code":18cs493}
  List<dynamic> subjects;

  Map<String, dynamic> tutor;
  bool isEmpty;
  Staff({
    this.name,
    this.mail,
    this.locationPrivacy,
    this.location,
    this.phoneNumber,
    this.subjects,
    this.tutor,
  }) {
    this.isEmpty = false;
  }
  factory Staff.empty() {
    Staff staff = Staff();
    staff.isEmpty = true;
    return staff;
  }
  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
        name: json["name"],
        mail: json["mail"],
        locationPrivacy: json["locationPrivacy"],
        location: json["location"],
        phoneNumber: json["phoneNumber"],
        subjects: json["subjects"],
        tutor: json["tutor"]);
  }

  static Future<Staff> create(String mailName) async {
    Map<String, dynamic> json = await getIt<StaffDatabase>().getStaff(mailName);
    if (json == null) {
      return Staff.empty();
    }
    return Staff.fromJson(json);
  }

  Future<void> loadData(String mailName) async {
    Map<String, dynamic> json = await getIt<StaffDatabase>().getStaff(mailName);
    name = json["name"];
    mail = json["mail"];
    locationPrivacy = json["locationPrivacy"];
    location = json["location"];
    phoneNumber = json["phoneNumber"];
    subjects = json["subjects"];
    tutor = json["tutor"];
    isEmpty = false;
  }

  Future<void> updateDetails(
      {String name,
      String email,
      String phoneNumber,
      bool locationPrivacy,
      List<Map<String, dynamic>> subjectMapList,
      Map<String, dynamic> tutorMap}) {
    this.name = name;
    this.mail = email;
    this.locationPrivacy = locationPrivacy;

    this.phoneNumber = phoneNumber;
    this.subjects = subjectMapList;
    this.tutor = tutorMap.isEmpty ? null : tutorMap;
    isEmpty = false;
    Logger().wtf("$mail");
    getIt<StaffDatabase>().updateDetails(
        name: name,
        locationPrivacy: locationPrivacy,
        phoneNumber: phoneNumber,
        subjectMapList: subjectMapList,
        tutorMap: tutorMap,
        mail: this.mail);
  }

  void clearData() {
    name = null;
    mail = null;
    locationPrivacy = null;
    location = null;
    phoneNumber = null;
    subjects = null;
    tutor = null;
    isEmpty = true;
  }
}
