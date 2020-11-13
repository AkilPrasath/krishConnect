import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:krish_connect/main.dart';
import 'package:krish_connect/service/database.dart';
import 'package:krish_connect/widgets/appBackground.dart';
import 'package:krish_connect/widgets/customExpandableTile.dart';

class ViewAllAnnouncementPage extends StatefulWidget {
  @override
  _ViewAllAnnouncementPageState createState() =>
      _ViewAllAnnouncementPageState();
}

class _ViewAllAnnouncementPageState extends State<ViewAllAnnouncementPage>
    with TickerProviderStateMixin {
  bool resize = false;
  bool showButton = false;
  double screenWidth, screenHeight;
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
        body: Container(
          height: screenHeight,
          width: screenWidth,
          child: ListView.builder(
              itemCount: 1,
              shrinkWrap: true,
              itemBuilder: (context, int index) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      resize = !resize;
                    });
                  },
                  child: AnimatedNewsCard(
                    vsync: this,
                    announcementMap: {},
                    resized: resize,
                  ),
                );
              }
              // Text("AnnounceMents",
              //     style: TextStyle(
              //       fontSize: 20,
              //       color: Colors.blue,
              //     )),
              // SizedBox(height: 30),

              ),
        ),
      ),
    ));
  }
}

class AnimatedNewsCard extends StatelessWidget {
  double screenWidth, screenHeight;
  bool resized;
  TickerProvider vsync;
  String relativeTime;
  Map<String, dynamic> announcementMap;

  AnimatedNewsCard({
    @required this.resized,
    @required this.vsync,
    @required this.announcementMap,
  }) {
    relativeTime = "2 hours ago";
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
                        // "${widget.announcementMap["name"][widget.announcementMap["name"].keys.toList()[0]]}",
                        "Priya A",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      FaIcon(
                        // widget.announcementMap["priority"] == 0
                        true ? FontAwesomeIcons.bell : FontAwesomeIcons.fire,
                        // color: widget.announcementMap["priority"] == 0
                        color: true ? Colors.green : Colors.red,
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        // widget.announcementMap["priority"] == 0
                        true ? "Neutral" : 'High',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color:
                              // widget.announcementMap["priority"] == 0
                              true ? Colors.green : Colors.red,
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
                  // "$relativeTime"
                  "2 hours ago",
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
                child: Text(
                  "Students choose the elective. I have shared the google sheets link. https://docs.google.com/spreadsheets/d/1hmukk7OGCrALyfjcK_wdtRCo7Nm-2rVUOrirn-0PlN0/edit?usp=sharing",
                  overflow: !resized ? TextOverflow.ellipsis : null,
                  maxLines: !resized ? 2 : null,
                ),
              ),
            ),
            // Spacer(),

            // widget.announcementMap["type"] == "broadcast"
            resized
                ? true
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
                      )
                : Container(),
          ],
        ),
      ),
    );
  }

  Future<void> sendResponse({BuildContext context, bool response}) async {
    // await getIt<Database>().setAnnouncementResponse(
    //     widget.announcementMap["timestamp"],
    //     widget.announcementMap["name"].keys.toList()[0],
    //     response);

    // _scaffoldKey.currentState.showSnackBar(SnackBar(
    //   duration: Duration(seconds: 1),
    //   content: Text("Responded successfully!"),
    // ));
  }
}
