import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:krish_connect/UI/student/ViewAllContacts.dart';
import 'package:krish_connect/data/staff.dart';
import 'package:krish_connect/data/student.dart';
import 'package:krish_connect/main.dart';
import 'package:krish_connect/service/studentDatabase.dart';
import 'package:krish_connect/widgets/appBackground.dart';
import 'package:logger/logger.dart';

class TrackStudentsPage extends StatefulWidget {
  @override
  _TrackStudentsPageState createState() => _TrackStudentsPageState();
}

class _TrackStudentsPageState extends State<TrackStudentsPage> {
  double screenWidth, screenHeight;
  List<QueryDocumentSnapshot> list;
  String selectedClass = "";
  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: AppBackground(
        screenHeight: screenHeight,
        screenWidth: screenWidth,
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                Navigator.pop(context);
              },
              child: Center(
                child: Icon(
                  Icons.chevron_left,
                  color: Colors.blue[700],
                ),
              ),
            ),
            title: Text(
              "KRISH CONNECT",
              style: TextStyle(
                color: Colors.blue[700],
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                FutureBuilder(
                  future: getIt.getAsync<Staff>(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return DropdownButton(
                        value: selectedClass,
                        onChanged: (value) {
                          setState(() {
                            selectedClass = value;
                          });
                        },
                        items: snapshot.data.subjects
                            .map((subMap) {
                              return DropdownMenuItem(
                                  value: subMap["semester"].toString() +
                                      subMap["department"].toString() +
                                      subMap["section"].toString(),
                                  child: Text(subMap["semester"].toString() +
                                      subMap["department"].toString() +
                                      subMap["section"].toString()));
                            })
                            .cast<DropdownMenuItem<String>>()
                            .toList(),
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
                FutureBuilder<List<QueryDocumentSnapshot>>(
                    future: getIt.get<StudentDatabase>().getAllStudents(),
                    builder: (context, snapshot) {
                      list = [];
                      snapshot.data.forEach((doc) {
                        String className = doc.data()["semester"].toString() +
                            doc.data()["department"] +
                            doc.data()["section"];
                        if (className == selectedClass) {
                          list.add(doc);
                        }
                      });

                      return Container(
                        height: screenHeight,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: GridView.builder(
                            physics: BouncingScrollPhysics(),
                            itemCount: list.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemBuilder: (context, index) {
                              return InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  bottomSheet(context, snapshot.data[index].id);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: StaffGridItem(
                                    queryDoc: list[index],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bottomSheet(context, String docId) {
    showBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return StreamBuilder<DocumentSnapshot>(
              stream: getIt<StudentDatabase>().getStaffStream(docId),
              builder: (context, snapshot) {
                if (snapshot.hasData)
                  return Container(
                    height: 0.35 * screenHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          offset: const Offset(0.0, 5.0),
                          blurRadius: 20.0,
                          spreadRadius: 10.0,
                        ),
                      ],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16),
                        Center(
                          child: Text(
                            "${snapshot.data.data()["name"]}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.compass,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Location",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text("${snapshot.data.data()["location"]}"),
                              SizedBox(width: 6),
                              Text(
                                "${Jiffy(snapshot.data.data()["time"].toDate()).fromNow()}",
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.chair,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Status     ",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text("Available"),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.phoneAlt,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Contact  ",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text("${snapshot.data.data()["phoneNumber"]}"),
                              Spacer(),
                              Material(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                elevation: 1,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () async {
                                    String number =
                                        snapshot.data.data()["phoneNumber"];
                                    //set the number here
                                    bool res = await FlutterPhoneDirectCaller
                                        .callNumber(number);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        FaIcon(
                                          FontAwesomeIcons.phone,
                                          color: Colors.blue,
                                          size: 14,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Text(
                                            "Call",
                                            style: TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Spacer(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                return Center(
                  child: CircularProgressIndicator(),
                );
              });
        });
  }
}
