import 'dart:convert';

import 'package:background_fetch/background_fetch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jiffy/jiffy.dart';
import 'package:krish_connect/UI/dashboard/dashboardScreen.dart';
import 'package:krish_connect/UI/requestsStudent.dart';
import 'package:krish_connect/UI/viewAllAnnouncements.dart';
import 'package:krish_connect/data/fenceData.dart';
import 'package:krish_connect/data/student.dart';
import 'package:krish_connect/main.dart';
import 'package:krish_connect/service/Geofencing.dart';
import 'package:krish_connect/service/database.dart';
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
  int currentIndex;
  AnimationController _controller;
  Stream requestStream;
  Animation<Offset> _slideAnimation;
  Animation<double> _scaleAnimation;
  List<Map<String, dynamic>> requestList = [];
  int i = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = 0;
    Geolocator.requestPermission();
    initPlatformState().then((value) {
      BackgroundFetch.start();
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
                title: Text(
                  "KRISH CONNECT",
                  style: TextStyle(
                    color: Colors.blue[700],
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
                                "Hi Akil,",
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
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                physics: BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                itemCount: 5,
                                itemBuilder: (context, int index) {
                                  var name = [
                                    "Akil",
                                    "Abishek",
                                    "Akshaya",
                                    "Mr Stark",
                                    "Nisha"
                                  ];
                                  return StoryItem(
                                      onTap: () {
                                        bottomSheet(context);
                                      },
                                      screenWidth: screenWidth,
                                      screenHeight: screenHeight,
                                      name: name[index]);
                                },
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                              child: Row(
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
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting)
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              if (snapshot.hasData)
                                return StreamBuilder<dynamic>(
                                  stream: getIt<Database>()
                                      .announcementsStream(snapshot.data),
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
                                        child: Lottie.asset(false
                                            ? "assets/lottie/announcement.json"
                                            : "assets/lottie/33356-hacker.json"),
                                      );
                                    }
                                    if (snapshot.hasData)
                                      return Container(
                                        height: 0.249 * screenHeight,
                                        child: Swiper(
                                          onTap: (int index) {},
                                          onIndexChanged: (int index) {},
                                          layout: SwiperLayout.STACK,
                                          itemCount: snapshot.data.length,
                                          itemWidth: 0.8 * screenWidth,
                                          itemBuilder: (context, int index) {
                                            return InkWell(
                                              onTap: () async {
                                                await showDetailedAnnouncement(
                                                    context: context,
                                                    announcementMap:
                                                        snapshot.data[index]);
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
                                  },
                                );
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
                                  print("loading future");
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (!snapshot.hasData) {
                                  // print("no data");
                                  return Center(
                                    child: Text("no data in future"),
                                  );
                                }
                                if (snapshot.hasData)
                                  return StreamBuilder<dynamic>(
                                      stream: getIt<Database>()
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
                                                      await getIt<Database>()
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
        return true
            ? Center(
                child: ExpandedNewsCard(
                  announcementMap: announcementMap,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
              )
            : Center(
                child: Material(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  color: Colors.transparent,
                  child: Container(
                    // color: Colors.white,
                    width: 0.8 * screenWidth,
                    height: 0.5 * screenHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [],
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          // Text("Announcements",style: ,),
                          SizedBox(
                            height: 40,
                          ),
                          Text(
                              "Students please select your elective subjects. I have shared the google sheets link."),
                        ],
                      ),
                    ),
                  ),
                ),
              );
      },
    );
  }

  bottomSheet(context) {
    showBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            height: 0.5 * screenHeight,
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
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: StoryItem(
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      name: "A",
                      style: TextStyle(
                        fontSize: 1,
                      ),
                      onTap: () {},
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    "Ms Gwen Stacy",
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
                      Text("MCT block"),
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
                      Text("9080735855"),
                      Spacer(),
                      Material(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 1,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () async {
                            const number = '9080735855'; //set the number here
                            bool res =
                                await FlutterPhoneDirectCaller.callNumber(
                                    number);
                            print(res);
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
    await getIt<Database>().setAnnouncementResponse(
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
    await getIt<Database>().setAnnouncementResponse(
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
