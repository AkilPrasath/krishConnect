import 'package:background_fetch/background_fetch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jiffy/jiffy.dart';
import 'package:krish_connect/UI/login.dart';
import 'package:krish_connect/UI/staff/dashboard/staff_dashboard_screen.dart';
import 'package:krish_connect/UI/staff/post_announcements.dart';
import 'package:krish_connect/UI/staff/track_students.dart';
import 'package:krish_connect/UI/staff/viewAllRequestsPage.dart';
import 'package:krish_connect/UI/student/dashboard/student_dashboard.dart';

import 'package:krish_connect/data/staff.dart';
import 'package:krish_connect/main.dart';
import 'package:krish_connect/service/Geofencing.dart';
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
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      LocationPermission locationPermission =
          await Geolocator.requestPermission();
      if (!(locationPermission == LocationPermission.denied ||
          locationPermission == LocationPermission.deniedForever)) {
        initPlatformState().then((value) {
          BackgroundFetch.start();
        });
      }
    });
  }

  Future<void> initPlatformState() async {
    // Configure BackgroundFetch.
    BackgroundFetch.configure(
            BackgroundFetchConfig(
              minimumFetchInterval: 15,
              forceAlarmManager: false,
              stopOnTerminate: false,
              startOnBoot: true,
              enableHeadless: true,
              requiresBatteryNotLow: false,
              requiresCharging: false,
              requiresStorageNotLow: false,
              requiresDeviceIdle: false,
              requiredNetworkType: NetworkType.NONE,
            ),
            _onBackgroundFetch)
        .then((int status) {
      print('[BackgroundFetch] configure success: $status');
    }).catchError((e) {
      print('[BackgroundFetch] configure ERROR: $e');
    });

    // Schedule a "one-shot" custom-task in 10000ms.
    // These are fairly reliable on Android (particularly with forceAlarmManager) but not iOS,
    // where device must be powered (and delay will be throttled by the OS).
    BackgroundFetch.scheduleTask(TaskConfig(
        taskId: "com.transistorsoft.customtask",
        delay: 10000,
        periodic: false,
        forceAlarmManager: true,
        stopOnTerminate: false,
        enableHeadless: true));

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  void _onBackgroundFetch(String taskId) async {
    // This is the fetch-event callback.
    print("Akil Background event $taskId");
    Geofencing fence = Geofencing();
    await fence.updateLocationCallback();

    if (taskId == "flutter_background_fetch") {
      // Schedule a one-shot task when fetch event received (for testing).
      BackgroundFetch.scheduleTask(TaskConfig(
          taskId: "com.transistorsoft.customtask",
          delay: 5000,
          periodic: false,
          forceAlarmManager: true,
          stopOnTerminate: false,
          enableHeadless: true));
    }

    // IMPORTANT:  You must signal completion of your fetch task or the OS can punish your app
    // for taking too long in the background.
    BackgroundFetch.finish(taskId);
  }

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
                        title: Hero(
                          tag: Key("appLogo"),
                          child: Text(
                            "KRISH CONNECT",
                            style: TextStyle(
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ),
                      backgroundColor: Colors.transparent,
                      body: SingleChildScrollView(
                        child: Column(
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
                                                  onIndexChanged:
                                                      (int index) {},
                                                  layout: SwiperLayout.STACK,
                                                  itemCount:
                                                      snapshot.data.length,
                                                  itemWidth: 0.8 * screenWidth,
                                                  itemBuilder:
                                                      (context, int index) {
                                                    return StudentPermissionCard(
                                                        screenWidth:
                                                            screenWidth,
                                                        announcementMap:
                                                            snapshot
                                                                .data[index]);
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
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Announcements",
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
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PostAnnouncementPage()));
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Container(
                                    width: double.maxFinite,
                                    height: screenHeight * 0.2,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 8),
                                          child: Lottie.asset(
                                              "assets/lottie/phone_announcement.json"),
                                        ),
                                        Flexible(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                FaIcon(
                                                  FontAwesomeIcons.plusCircle,
                                                  color: Colors.blue[600],
                                                  size: 40,
                                                ),
                                                SizedBox(height: 8),
                                                Flexible(
                                                    child: Text(
                                                  "Communicate the SKCET way...",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.blueGrey,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                )),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Track Students",
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
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: InkWell(
                                onTap: () async {
                                  Staff staff = await getIt.getAsync<Staff>();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              TrackStudentsPage(
                                                staff: staff,
                                              )));
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Container(
                                    width: double.maxFinite,
                                    height: screenHeight * 0.2,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                FaIcon(
                                                  FontAwesomeIcons
                                                      .searchLocation,
                                                  color: Colors.blue[600],
                                                  size: 40,
                                                ),
                                                SizedBox(height: 8),
                                                Flexible(
                                                    child: Text(
                                                  "Know your students better...",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.blueGrey,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                )),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 8),
                                          child: Lottie.asset(
                                              "assets/lottie/gps.json"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
              builder: (context) {
                return Center(
                    child: ExpandedStudentPermissionCard(
                        announcementMap: announcementMap,
                        screenWidth: screenWidth));
              });
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
                    "${announcementMap["body"]}",
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
        onTap: () {},
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 8),
                    child: LinkWell(
                      "${announcementMap["body"]}",
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
                            await sendResponse(
                                context: context, response: true);
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
                            await sendResponse(
                                context: context, response: false);
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
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ViewAllRequestsPage()));
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 8, right: 8, bottom: 8.0),
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
