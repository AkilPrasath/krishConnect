import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:krish_connect/UI/login.dart';
import 'package:krish_connect/UI/staff/dashboard/staff_dashboard_screen.dart';
import 'package:krish_connect/UI/staff/viewAllRequestsPage.dart';
import 'package:krish_connect/UI/student/dashboard/student_dashboard.dart';

import 'package:krish_connect/data/staff.dart';
import 'package:krish_connect/main.dart';
import 'package:krish_connect/service/authentication.dart';
import 'package:krish_connect/service/staffDatabase.dart';
import 'package:krish_connect/service/studentDatabase.dart';
import 'package:krish_connect/widgets/appBackground.dart';
import 'package:linkwell/linkwell.dart';
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class StaffDashboard extends StatefulWidget {
  @override
  _StaffDashboardState createState() => _StaffDashboardState();
}

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class _StaffDashboardState extends State<StaffDashboard> {
  double screenHeight;
  double screenWidth;
  AnimationController _controller;
  Animation<Offset> _slideAnimation;
  Animation<double> _scaleAnimation;
  @override
  Widget build(BuildContext context) {
    _controller =
        Provider.of<StaffDrawerAnimationProvider>(context, listen: true)
            .controller;
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0), end: Offset(0.76, 0))
        .animate(
            CurvedAnimation(parent: _controller, curve: Curves.slowMiddle));
    _scaleAnimation = Tween<double>(begin: 1, end: 0.9).animate(
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onPanUpdate: (details) {
            //on swiping left
            if (details.delta.dx < -6) {
              if (_controller.status == AnimationStatus.completed) {
                Provider.of<StaffDrawerAnimationProvider>(context, listen: true)
                    .toggle();
              }
            }
          },
          onTap: () {
            if (_controller.status == AnimationStatus.completed) {
              _controller.reverse();
            }
          },
          child: AppBackground(
            screenHeight: screenHeight,
            screenWidth: screenWidth,
            child: FutureBuilder<Staff>(
                future: getIt.getAsync<Staff>(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Scaffold(
                      key: _scaffoldKey,
                      appBar: AppBar(
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        leading: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () {
                            Provider.of<StaffDrawerAnimationProvider>(context,
                                    listen: true)
                                .toggle();
                          },
                          child: Center(
                            child: FaIcon(
                              FontAwesomeIcons.bars,
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
                      body: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          snapshot.data.tutor == null
                              ? Container()
                              : Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 8),
                                          child: Row(
                                            children: [
                                              Text(
                                                "Recent Requests",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Icon(Icons.chevron_right),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 0.249 * screenHeight,
                                      child: StreamBuilder(
                                          stream: getIt<StaffDatabase>()
                                              .requestsStream(snapshot.data),
                                          builder: (context, snapshot) {
                                            if (snapshot.data == null) {
                                              return Lottie.asset(
                                                  "assets/lottie/33356-hacker.json");
                                            }
                                            if (snapshot.data.length == 0) {
                                              return Lottie.asset(
                                                  "assets/lottie/33356-hacker.json");
                                            }
                                            if (snapshot.hasData) {
                                              return Swiper(
                                                onTap: (int index) {},
                                                onIndexChanged: (int index) {},
                                                layout: SwiperLayout.STACK,
                                                itemCount: snapshot.data.length,
                                                itemWidth: 0.8 * screenWidth,
                                                itemBuilder:
                                                    (context, int index) {
                                                  return StudentPermissionCard(
                                                      screenWidth: screenWidth,
                                                      announcementMap:
                                                          snapshot.data[index]);
                                                },
                                              );
                                            } else {
                                              return Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            }
                                          }),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    );
                  } else {
                    return Text("loading");
                  }
                }),
          ),
        ),
      ),
    );
  }
}

class StudentPermissionCard extends StatelessWidget {
  StudentPermissionCard({
    Key key,
    @required this.announcementMap,
    @required this.screenWidth,
  }) : super(key: key);

  final double screenWidth;
  final Map<String, dynamic> announcementMap;
  String relativeTime;
  @override
  Widget build(BuildContext context) {
    relativeTime = Jiffy(announcementMap["timestamp"].toDate()).fromNow();
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          showDialog(
            context: context,
            builder: (context){
              return Center(child: ExpandedStudentPermissionCard(announcementMap: announcementMap, screenWidth:screenWidth));
            }
          );
        },
        child: Container(
          width: 0.8 * screenWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 12.0,
                      top: 18,
                    ),
                    child: Row(
                      children: [
                        Text(
                          announcementMap["name"],
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          announcementMap["rollno"],
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer(),
                        Text(
                          announcementMap["type"],
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(width: 20),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 12.0,
                      top: 4,
                    ),
                    child: Text(
                      "$relativeTime",
                      style: TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: LinkWell(
                    // "${announcementMap["body"]}",
                    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
                    linkStyle: TextStyle(
                      fontSize: 13,
                      color: Colors.blue[700],
                      decoration: TextDecoration.underline,
                    ),
                    style: TextStyle(color: Colors.grey[800]),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                // Spacer(),
                // announcementMap["type"] == "broadcast"
                //     ? Row(
                //         mainAxisAlignment: MainAxisAlignment.start,
                //         children: [
                //           SizedBox(
                //             width: 16,
                //           ),
                //           InkWell(
                //             onTap: () async {
                //               // await sendResponse(
                //               //     context: context, response: true);
                //             },
                //             child: Padding(
                //               padding: const EdgeInsets.all(8.0),
                //               child: Row(
                //                 mainAxisSize: MainAxisSize.min,
                //                 children: [
                //                   Padding(
                //                     padding: const EdgeInsets.symmetric(
                //                         horizontal: 8.0),
                //                     child: FaIcon(
                //                       FontAwesomeIcons.check,
                //                       color: Colors.green,
                //                       size: 20,
                //                     ),
                //                   ),
                //                   Text(
                //                     "Mark as Read",
                //                     style: TextStyle(
                //                       fontWeight: FontWeight.w600,
                //                       color: Colors.green[700],
                //                     ),
                //                   ),
                //                 ],
                //               ),
                //             ),
                //           ),
                //         ],
                //       )
                // :
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: FlatButton(
                        child: FaIcon(
                          FontAwesomeIcons.check,
                          color: Colors.green,
                          size: 20,
                        ),
                        onPressed: () async {
                          await sendResponse(context: context, response: true);
                        },
                      ),
                    ),
                    Flexible(
                      child: FlatButton(
                        child: FaIcon(
                          FontAwesomeIcons.times,
                          color: Colors.yellow[900],
                          size: 20,
                        ),
                        onPressed: () async {
                          await sendResponse(context: context, response: false);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Future<void> sendResponse({BuildContext context, bool response}) async {
    await getIt<StaffDatabase>().setRequestResponse(
        response, announcementMap["timestamp"], announcementMap["rollno"]);

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      duration: Duration(seconds: 1),
      content: Text("Responded successfully!"),
    ));
  }
  

}

class ExpandedStudentPermissionCard extends StatelessWidget {
  ExpandedStudentPermissionCard({
    Key key,
    @required this.announcementMap,
    @required this.screenWidth,
  }) : super(key: key);

  final double screenWidth;
  final Map<String, dynamic> announcementMap;
  String relativeTime;
  @override
  Widget build(BuildContext context) {
    relativeTime = Jiffy(announcementMap["timestamp"].toDate()).fromNow();
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
         
        },
        child: Container(
          width: 0.8 * screenWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: SingleChildScrollView(
                          child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 12.0,
                        top: 18,
                      ),
                      child: Row(
                        children: [
                          Text(
                            announcementMap["name"],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            announcementMap["rollno"],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Spacer(),
                          Text(
                            announcementMap["type"],
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(width: 20),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 12.0,
                        top: 4,
                      ),
                      child: Text(
                        "$relativeTime",
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                    child: LinkWell(
                      // "${announcementMap["body"]}",
                      '''aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa''',
                      linkStyle: TextStyle(
                        fontSize: 13,
                        color: Colors.blue[700],
                        decoration: TextDecoration.underline,
                      ),
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                  ),
                  // Spacer(),
                  // announcementMap["type"] == "broadcast"
                  //     ? Row(
                  //         mainAxisAlignment: MainAxisAlignment.start,
                  //         children: [
                  //           SizedBox(
                  //             width: 16,
                  //           ),
                  //           InkWell(
                  //             onTap: () async {
                  //               // await sendResponse(
                  //               //     context: context, response: true);
                  //             },
                  //             child: Padding(
                  //               padding: const EdgeInsets.all(8.0),
                  //               child: Row(
                  //                 mainAxisSize: MainAxisSize.min,
                  //                 children: [
                  //                   Padding(
                  //                     padding: const EdgeInsets.symmetric(
                  //                         horizontal: 8.0),
                  //                     child: FaIcon(
                  //                       FontAwesomeIcons.check,
                  //                       color: Colors.green,
                  //                       size: 20,
                  //                     ),
                  //                   ),
                  //                   Text(
                  //                     "Mark as Read",
                  //                     style: TextStyle(
                  //                       fontWeight: FontWeight.w600,
                  //                       color: Colors.green[700],
                  //                     ),
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),
                  //           ),
                  //         ],
                  //       )
                  // :
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: FlatButton(
                          child: FaIcon(
                            FontAwesomeIcons.check,
                            color: Colors.green,
                            size: 20,
                          ),
                          onPressed: () async {
                            await sendResponse(context: context, response: true);
                          },
                        ),
                      ),
                      Flexible(
                        child: FlatButton(
                          child: FaIcon(
                            FontAwesomeIcons.times,
                            color: Colors.yellow[900],
                            size: 20,
                          ),
                          onPressed: () async {
                            await sendResponse(context: context, response: false);
                          },
                        ),
                      ),
                    ],
                  ),
                  Align(
                alignment: Alignment.center,
                child: InkWell(
                  onTap: () {
                    // Navigator.pushReplacementNamed(
                    //   context,
                    //   ViewAllAnnouncementPage.id,
                    // );
                    Navigator.pushReplacement(context, MaterialPageRoute(builder:(context)=>ViewAllRequestsPage() ));
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 8, right: 8, bottom: 8.0),
                    child: Text(
                      "View All",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        decoration: TextDecoration.underline,
                        color: Colors.blue[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


    
  Future<void> sendResponse({BuildContext context, bool response}) async {
    await getIt<StaffDatabase>().setRequestResponse(
        response, announcementMap["timestamp"], announcementMap["rollno"]);

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      duration: Duration(seconds: 1),
      content: Text("Responded successfully!"),
    ));
  }
}
  
