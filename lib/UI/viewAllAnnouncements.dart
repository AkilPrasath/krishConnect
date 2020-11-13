import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:krish_connect/data/student.dart';
import 'package:krish_connect/main.dart';
import 'package:krish_connect/service/database.dart';
import 'package:krish_connect/widgets/appBackground.dart';
import 'package:krish_connect/widgets/customExpandableTile.dart';
import 'package:lottie/lottie.dart';

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
        body: Container(
          height: screenHeight,
          width: screenWidth,
          child: FutureBuilder<Student>(
            future: getIt.getAsync<Student>(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return Center(
                  child: CircularProgressIndicator(),
                );
              if (snapshot.hasData){
                student=snapshot.data;
                return StreamBuilder<dynamic>(
                  stream: getIt<Database>().allAnnouncementsStream(snapshot.data),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
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
                    if (snapshot.hasData){
                      print(snapshot.data[0]);
                      return ListView.builder(
                          itemCount: snapshot.data.length,
                          shrinkWrap: true,
                          itemBuilder: (context, int index) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  resize = !resize;
                                });
                              },
                              child: AnimatedNewsCard(
                                student: student,
                                vsync: this,
                                announcementMap: snapshot.data[0],
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

                          );
                  }
                  },
                );}
            },
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
  TickerProvider vsync;
  String relativeTime;
  Map<String, dynamic> announcementMap;

  AnimatedNewsCard({
    @required this.resized,
    @required this.vsync,
    @required this.announcementMap,
    @required this.student,
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
                        "${announcementMap["name"][announcementMap["name"].keys.toList()[0]]}",
                        // "Priya A",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      FaIcon(
                        announcementMap["priority"] == 0
                         ? FontAwesomeIcons.bell : FontAwesomeIcons.fire,
                        color: announcementMap["priority"] == 0
                        ? Colors.green : Colors.red,
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        announcementMap["priority"] == 0?
                         "Neutral" : 'High',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color:
                              announcementMap["priority"] == 0
                              ?Colors.green : Colors.red,
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

            //
            resized
                ?announcementMap["type"] == "broadcast"
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
                              child: announcementMap["reponse"][student.rollno]==null?Row(
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
                              ):
                              Center(child: Text("Read",style:TextStyle(
                                color:Colors.grey[500],
                              ),),),
                            ),
                          ),
                        ],
                      )
                    : announcementMap["response"][student.rollno]==null?Row(
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
                      ):Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(child: announcementMap["response"][student.rollno]?Text("Interested",style:TextStyle(color:Colors.grey[500])):Text("Not Interested",style:TextStyle(
                          color:Colors.grey[500],
                        )),),
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
