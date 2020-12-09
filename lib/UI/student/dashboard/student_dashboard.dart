import 'dart:convert';

import 'package:background_fetch/background_fetch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jiffy/jiffy.dart';
import 'package:krish_connect/UI/student/ViewAllContacts.dart';
import 'package:krish_connect/UI/student/dashboard/student_dashboard_screen.dart';
import 'package:krish_connect/UI/student/student_requests.dart';
import 'package:krish_connect/UI/student/viewAllAnnouncements.dart';
import 'package:krish_connect/data/fenceData.dart';
import 'package:krish_connect/data/student.dart';
import 'package:krish_connect/main.dart';
import 'package:krish_connect/service/Geofencing.dart';
import 'package:krish_connect/service/studentDatabase.dart';
import 'package:krish_connect/widgets/appBackground.dart';
import 'package:krish_connect/widgets/columnBuilder.dart';
import 'package:krish_connect/widgets/customExpandableTile.dart';
import 'package:linkwell/linkwell.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class DashBoard extends StatefulWidget {
  @override
  _DashBoardState createState() => _DashBoardState();
}

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class _DashBoardState extends State<DashBoard> with TickerProviderStateMixin {
  double screenWidth;
  double screenHeight;
  String studentName;
  bool studentFutureFlag;
  AnimationController _controller;
  Animation<Offset> _slideAnimation;
  Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    studentFutureFlag = true;
    studentName = "";
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

  void refreshName() {
    if (studentFutureFlag) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _controller =
        Provider.of<AnimationProvider>(context, listen: true).controller;
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
                Provider.of<AnimationProvider>(context, listen: true).toggle();
              }
            }
          },
          onTap: () {
            if (_controller.status == AnimationStatus.completed) {
              _controller.reverse();
            }
          },
          child: AppBackground(
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            child: Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                leading: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    Provider.of<AnimationProvider>(context, listen: true)
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
              body: Stack(
                children: [
                  Container(
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                "Hi $studentName,",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8),
                              child: Row(
                                children: [
                                  Text(
                                    "Suggested Connects ",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Icon(Icons.chevron_right),
                                  Spacer(),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ViewAllContacts()));
                                    },
                                    child: Text(
                                      "View All",
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        color: Colors.blue[800],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  FaIcon(
                                    FontAwesomeIcons.userAlt,
                                    size: 14,
                                    color: Colors.blue,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              width: screenWidth,
                              height: 0.13 * screenHeight,
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                border: Border.symmetric(
                                  horizontal: BorderSide(
                                    width: 0.25,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ),
                              child: FutureBuilder<List<QueryDocumentSnapshot>>(
                                  future: getIt<StudentDatabase>()
                                      .getStaffDetails(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return ListView.builder(
                                        padding: EdgeInsets.zero,
                                        physics: BouncingScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        itemCount: snapshot.data.length >= 6
                                            ? 6
                                            : snapshot.data.length,
                                        itemBuilder: (context, int index) {
                                          return StoryItem(
                                              onTap: () {
                                                bottomSheet(context,
                                                    snapshot.data[index].id);
                                              },
                                              screenWidth: screenWidth,
                                              screenHeight: screenHeight,
                                              name: snapshot.data[index]
                                                  .data()["name"]);
                                        },
                                      );
                                    } else {
                                      return Center(
                                        child: Text(
                                          "No suggested connects right now",
                                          style: TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      );
                                    }
                                  }),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                              child: Row(
                                // textBaseline: TextBaseline.alphabetic,
                                // crossAxisAlignment: CrossAxisAlignment.baseline,
                                children: [
                                  Text(
                                    "News for you",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Icon(Icons.chevron_right),
                                  Spacer(),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        ViewAllAnnouncementPage.id,
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8, right: 8, bottom: 8.0),
                                      child: Row(
                                        textBaseline: TextBaseline.alphabetic,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.baseline,
                                        children: [
                                          Text(
                                            "View All",
                                            style: TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                              color: Colors.blue[800],
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          FaIcon(FontAwesomeIcons.bullhorn,
                                              size: 15,
                                              color: Colors.blueGrey[700]),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          FutureBuilder<Student>(
                            future: getIt.getAsync<Student>(),
                            builder: (context, studentSnapshot) {
                              if (studentSnapshot.connectionState ==
                                  ConnectionState.waiting)
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              if (studentSnapshot.hasData) {
                                if (studentFutureFlag) {
                                  studentName = studentSnapshot.data.name;
                                  refreshName();
                                  studentFutureFlag = false;
                                }
                                return StreamBuilder<dynamic>(
                                  stream: getIt<StudentDatabase>()
                                      .announcementsStream(
                                          studentSnapshot.data),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting)
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    if (!snapshot.hasData) {
                                      return Center(
                                        child: Text("No Announcements"),
                                      );
                                    }
                                    if (snapshot.data.length == 0) {
                                      return Container(
                                        height: 0.2 * screenHeight,
                                        child: Lottie.asset(
                                            "assets/lottie/33356-hacker.json"),
                                      );
                                    }
                                    if (snapshot.hasData) {
                                      List announcementList = snapshot.data;
                                      announcementList
                                          .sort((dynamic b, dynamic a) {
                                        int val = a["timestamp"]
                                            .compareTo(b["timestamp"]);
                                        return val;
                                      });
                                      return Container(
                                        height: 0.249 * screenHeight,
                                        child: Swiper(
                                          onTap: (int index) {},
                                          onIndexChanged: (int index) {},
                                          layout: SwiperLayout.STACK,
                                          itemCount: announcementList.length,
                                          itemWidth: 0.8 * screenWidth,
                                          itemBuilder: (context, int index) {
                                            return InkWell(
                                              onTap: () async {
                                                await showDetailedAnnouncement(
                                                    context: context,
                                                    announcementMap:
                                                        announcementList[
                                                            index]);
                                              },
                                              child: NewsCard(
                                                screenWidth: screenWidth,
                                                announcementMap:
                                                    snapshot.data[index],
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    }
                                  },
                                );
                              }
                            },
                          ),
                          Align(
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
                                  Spacer(),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, RequestStudent.id);
                                    },
                                    child: FaIcon(
                                      FontAwesomeIcons.plusCircle,
                                      color: Colors.blue,
                                      size: 22,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          FutureBuilder<Student>(
                              future: getIt.getAsync<Student>(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (!snapshot.hasData) {
                                  // print("no data");
                                  return Center(
                                    child: Text("No data"),
                                  );
                                }
                                if (snapshot.hasData)
                                  return StreamBuilder<dynamic>(
                                      stream: getIt<StudentDatabase>()
                                          .requestsStream(snapshot.data),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }

                                        if (!snapshot.hasData) {
                                          return Center(
                                            child: Text("no data"),
                                          );
                                        }
                                        if (snapshot.data.length == 0) {
                                          return Center(
                                              child: Text(
                                                  "No Requests made yet "));
                                        }
                                        if (snapshot.hasData) {
                                          return ColumnBuilder(
                                            itemCount: snapshot.data.length,
                                            itemBuilder: (context, int index) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                child: Dismissible(
                                                  confirmDismiss:
                                                      (dismissDirection) async {
                                                    if (snapshot.data[index]
                                                            ["response"] ==
                                                        0) {
                                                      await getIt<
                                                              StudentDatabase>()
                                                          .deleteRequest(
                                                              snapshot.data[
                                                                      index][
                                                                  "timestamp"]);
                                                      Scaffold.of(context)
                                                          .showSnackBar(
                                                              SnackBar(
                                                        duration: Duration(
                                                            seconds: 1),
                                                        content: Text(
                                                            "Request Deleted Successfully!"),
                                                      ));
                                                      return Future.value(true);
                                                    } else {
                                                      Scaffold.of(context)
                                                          .showSnackBar(
                                                              SnackBar(
                                                        duration: Duration(
                                                            seconds: 1),
                                                        content: Text(
                                                            "Only pending requests can be deleted"),
                                                      ));
                                                      print("false");
                                                      return Future.value(
                                                          false);
                                                    }
                                                  },
                                                  direction: DismissDirection
                                                      .startToEnd,
                                                  background: Container(
                                                    color: Colors.red,
                                                    child: Row(
                                                      children: [
                                                        SizedBox(
                                                          width: 50,
                                                        ),
                                                        FaIcon(
                                                          FontAwesomeIcons
                                                              .trash,
                                                          color: Colors.white,
                                                        ),
                                                        SizedBox(
                                                          width: 20,
                                                        ),
                                                        Text(
                                                          "Release to Delete",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                        Spacer(
                                                          flex: 2,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  key: UniqueKey(),
                                                  child:
                                                      CustomExpandableListTile(
                                                    studentMap:
                                                        snapshot.data[index],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        }
                                      });
                              }),
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
    );
  }

  showDetailedAnnouncement(
      {BuildContext context, Map<String, dynamic> announcementMap}) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return Center(
          child: ExpandedNewsCard(
            announcementMap: announcementMap,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
          ),
        );
      },
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

class NewsCard extends StatelessWidget {
  NewsCard({
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
                        "${announcementMap["name"][announcementMap["name"].keys.toList()[0]]}",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      Tooltip(
                        message: "Announcement Priority",
                        child: FaIcon(
                          announcementMap["priority"] == 0
                              ? FontAwesomeIcons.bell
                              : FontAwesomeIcons.fire,
                          color: announcementMap["priority"] == 0
                              ? Colors.green
                              : Colors.red,
                          size: 18,
                        ),
                      ),
                      SizedBox(width: 6),
                      Tooltip(
                        message: "Announcement Priority",
                        child: Text(
                          announcementMap["priority"] == 0 ? "Neutral" : 'High',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: announcementMap["priority"] == 0
                                ? Colors.green
                                : Colors.red,
                          ),
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
              announcementMap["type"] == "broadcast"
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 16,
                        ),
                        InkWell(
                          onTap: () async {
                            await sendResponse(
                                context: context, response: true);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: FaIcon(
                                    FontAwesomeIcons.check,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                ),
                                Text(
                                  "Mark as Read",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
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
            ],
          ),
        ),
      ),
    );
  }

  Future<void> sendResponse({BuildContext context, bool response}) async {
    await getIt<StudentDatabase>().setAnnouncementResponse(
        announcementMap["timestamp"],
        announcementMap["name"].keys.toList()[0],
        response);

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      duration: Duration(seconds: 1),
      content: Text("Responded successfully!"),
    ));
  }
}

class ExpandedNewsCard extends StatelessWidget {
  ExpandedNewsCard({
    Key key,
    @required this.announcementMap,
    @required this.screenWidth,
    @required this.screenHeight,
  }) : super(key: key);

  final double screenWidth, screenHeight;
  final Map<String, dynamic> announcementMap;
  String relativeTime;
  @override
  Widget build(BuildContext context) {
    relativeTime = Jiffy(announcementMap["timestamp"].toDate()).fromNow();
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: 0.8 * screenWidth,
        // height: 0.4 * screenHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
                        "${announcementMap["name"][announcementMap["name"].keys.toList()[0]]}",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      Tooltip(
                        message: "Announcement Priority",
                        child: FaIcon(
                          announcementMap["priority"] == 0
                              ? FontAwesomeIcons.bell
                              : FontAwesomeIcons.fire,
                          color: announcementMap["priority"] == 0
                              ? Colors.green
                              : Colors.red,
                          size: 18,
                        ),
                      ),
                      SizedBox(width: 6),
                      Tooltip(
                        message: "Announcement Priority",
                        child: Text(
                          announcementMap["priority"] == 0 ? "Neutral" : 'High',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: announcementMap["priority"] == 0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      // InkWell(
                      //   onTap: () {},
                      //   child: Text(
                      //     "View All",
                      //     style: TextStyle(
                      //       fontStyle: FontStyle.italic,
                      //       decoration: TextDecoration.underline,
                      //       color: Colors.blue[800],
                      //       fontWeight: FontWeight.w600,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
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
                  '''${announcementMap["body"]}''',
                  linkStyle: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 13.5,
                    decoration: TextDecoration.underline,
                  ),
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                ),
              ),
              // Spacer(),
              announcementMap["type"] == "broadcast"
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 16,
                        ),
                        InkWell(
                          onTap: () async {
                            await sendResponse(
                                context: context, response: true);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: FaIcon(
                                    FontAwesomeIcons.check,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                ),
                                Text(
                                  "Mark as Read",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
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
                    Navigator.pushReplacementNamed(
                      context,
                      ViewAllAnnouncementPage.id,
                    );
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
    );
  }

  Future<void> sendResponse({BuildContext context, bool response}) async {
    await getIt<StudentDatabase>().setAnnouncementResponse(
        announcementMap["timestamp"],
        announcementMap["name"].keys.toList()[0],
        response);

    Navigator.pop(context);
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      duration: Duration(seconds: 1),
      content: Text("Responded successfully!"),
    ));
  }
}

class StoryItem extends StatelessWidget {
  const StoryItem({
    Key key,
    @required this.screenWidth,
    @required this.screenHeight,
    @required this.name,
    @required this.onTap,
    this.style,
  }) : super(key: key);

  final double screenWidth;
  final double screenHeight;
  final Function onTap;
  final String name;
  final TextStyle style;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          width: 0.2 * screenWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 0.1 * screenHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xffFF6A83),
                      Color(0xffF98875),
                      Color(0xffF3A866),
                      // Colors.blue,
                      // Colors.blue[400],
                      // Colors.blue[200],
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      "${name.substring(0, 1)}",
                      style: TextStyle(
                        color: Color(0xffFF6A83),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  "$name",
                  style: style,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
