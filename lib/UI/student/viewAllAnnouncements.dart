import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:krish_connect/data/student.dart';
import 'package:krish_connect/main.dart';
import 'package:krish_connect/service/studentDatabase.dart';
import 'package:krish_connect/widgets/appBackground.dart';
import 'package:krish_connect/widgets/customExpandableTile.dart';
import 'package:linkwell/linkwell.dart';
import 'package:lottie/lottie.dart';

class ViewAllAnnouncementPage extends StatefulWidget {
  static final String id = "View all announcement page";
  @override
  _ViewAllAnnouncementPageState createState() =>
      _ViewAllAnnouncementPageState();
}

class _ViewAllAnnouncementPageState extends State<ViewAllAnnouncementPage>
    with TickerProviderStateMixin {
  int selectedCardIndex = -1;
  bool showButton = false;
  double screenWidth, screenHeight;
  Student student;

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
        child: AppBackground(
      screenHeight: screenHeight,
      screenWidth: screenWidth,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          title: Text(
            "Announcements",
            style: TextStyle(
              color: Colors.blue[700],
            ),
          ),
          backgroundColor: Colors.transparent,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Center(
                child: FaIcon(
              FontAwesomeIcons.chevronLeft,
              color: Colors.blue[700],
            )),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Container(
            height: screenHeight,
            width: screenWidth,
            child: FutureBuilder<Student>(
              future: getIt.getAsync<Student>(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                if (snapshot.hasData) {
                  student = snapshot.data;
                  return StreamBuilder<dynamic>(
                    stream: getIt<StudentDatabase>()
                        .allAnnouncementsStream(snapshot.data),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return Center(
                          child: CircularProgressIndicator(),
                        );

                      if (snapshot.data.length == 0 || !snapshot.hasData) {
                        return Container(
                          height: 0.2 * screenHeight,
                          child:
                              Lottie.asset("assets/lottie/33356-hacker.json"),
                        );
                      }
                      if (snapshot.hasData) {
                        List announcementList = snapshot.data;
                        announcementList.sort((dynamic b, dynamic a) {
                          int val = a["timestamp"].compareTo(b["timestamp"]);
                          return val;
                        });

                        return ListView.builder(
                            physics: BouncingScrollPhysics(),
                            itemCount: announcementList.length,
                            shrinkWrap: true,
                            itemBuilder: (context, int index) {
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedCardIndex =
                                        selectedCardIndex == index ? -1 : index;
                                  });
                                },
                                child: AnimatedNewsCard(
                                  student: student,
                                  announcementMap: announcementList[index],
                                  resized: index == selectedCardIndex,
                                ),
                              );
                            }
                            // Text("AnnounceMents",
                            //     style: TextStyle(
                            //       fontSize: 20,
                            //       color: Colors.blue,
                            //     )),
                            // SizedBox(height: 30),

                            );
                      }
                    },
                  );
                }
              },
            ),
          ),
        ),
      ),
    ));
  }
}

class AnimatedNewsCard extends StatelessWidget {
  double screenWidth, screenHeight;
  bool resized;
  Student student;
  bool responded;
  String relativeTime;
  Map<String, dynamic> announcementMap;

  AnimatedNewsCard({
    @required this.resized,
    @required this.announcementMap,
    @required this.student,
  }) {
    relativeTime = Jiffy(announcementMap["timestamp"].toDate()).fromNow();
    responded = (announcementMap["response"][student.rollno] != null);
  }
  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: 0.8 * screenWidth,
        height: !resized ? 0.2 * screenHeight : null,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Tooltip(
                message: "Announcement Priority",
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 12.0,
                    top: 18,
                  ),
                  child: Row(
                    children: [
                      Text(
                        "${announcementMap["name"][announcementMap["name"].keys.toList()[0]]}",
                        // "Priya A",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      FaIcon(
                        announcementMap["priority"] == 0
                            ? FontAwesomeIcons.bell
                            : FontAwesomeIcons.fire,
                        color: announcementMap["priority"] == 0
                            ? Colors.green
                            : Colors.red,
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        announcementMap["priority"] == 0 ? "Neutral" : 'High',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: announcementMap["priority"] == 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      SizedBox(width: 20),
                    ],
                  ),
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
            Flexible(
              child: Padding(
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
                  overflow:
                      !resized ? TextOverflow.ellipsis : TextOverflow.clip,
                  maxLines: !resized ? 2 : null,
                ),
              ),
            ),
            !resized
                ? Center(
                    child: FaIcon(
                      FontAwesomeIcons.angleDown,
                      color: Colors.blueAccent,
                    ),
                  )
                : SizedBox(),
            resized
                ? announcementMap["type"] == "broadcast"
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 16,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: announcementMap["response"]
                                        [student.rollno] ==
                                    null
                                ? InkWell(
                                    onTap: () async {
                                      await sendResponse(
                                          context: context, response: true);
                                    },
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
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      FaIcon(
                                        FontAwesomeIcons.checkDouble,
                                        color: Colors.grey[500],
                                        size: 12,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "Read",
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      )
                    : announcementMap["response"][student.rollno] == null
                        ? Row(
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
                          )
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: announcementMap["response"][student.rollno]
                                ? Text("Interested",
                                    style: TextStyle(color: Colors.grey[500]))
                                : Text("Not Interested",
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                    )),
                          )
                : Container(),
          ],
        ),
      ),
    );
  }

  Future<void> sendResponse({BuildContext context, bool response}) async {
    await getIt<StudentDatabase>().setAnnouncementResponse(
        announcementMap["timestamp"],
        announcementMap["name"].keys.toList()[0],
        response);

    Scaffold.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: 1),
      content: Text("Responded successfully!"),
    ));
  }
}
