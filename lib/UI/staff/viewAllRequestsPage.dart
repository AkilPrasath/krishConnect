import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:krish_connect/data/staff.dart';
import 'package:krish_connect/service/staffDatabase.dart';
import 'package:krish_connect/widgets/appBackground.dart';
import 'package:linkwell/linkwell.dart';
import 'package:lottie/lottie.dart';

import '../../main.dart';

class ViewAllRequestsPage extends StatefulWidget {
  static final String id = "View all Requests page";
  @override
  _ViewAllRequestsPageState createState() => _ViewAllRequestsPageState();
}

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class _ViewAllRequestsPageState extends State<ViewAllRequestsPage>
    with TickerProviderStateMixin {
  int selectedCardIndex = -1;
  bool showButton = false;
  double screenWidth, screenHeight;
  Staff staff;

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
        child: AppBackground(
      screenHeight: screenHeight,
      screenWidth: screenWidth,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          title: Text(
            "Review Requests",
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
            child: FutureBuilder<Staff>(
              future: getIt.getAsync<Staff>(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                if (snapshot.hasData) {
                  staff = snapshot.data;
                  return StreamBuilder<dynamic>(
                    stream:
                        getIt<StaffDatabase>().allRequestStream(snapshot.data),
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
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedCardIndex =
                                        selectedCardIndex == index ? -1 : index;
                                  });
                                },
                                child: AnimatedNewsCard(
                                  staff: staff,
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
  Staff staff;
  bool responded;
  String relativeTime;
  Map<String, dynamic> announcementMap;

  AnimatedNewsCard({
    @required this.resized,
    @required this.announcementMap,
    @required this.staff,
  }) {
    relativeTime = Jiffy(announcementMap["timestamp"].toDate()).fromNow();
    // responded = (announcementMap["response"][student.rollno] != null);
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
                "${announcementMap["body"]}",
                linkStyle: TextStyle(
                  fontSize: 13,
                  color: Colors.blue[700],
                  decoration: TextDecoration.underline,
                ),
                overflow: !resized ? TextOverflow.ellipsis : TextOverflow.clip,
                maxLines: !resized ? 2 : null,
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
            resized
                ? announcementMap["response"] == 0
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            announcementMap["response"] == 1
                                ? Text("Accepted",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600,
                                    ))
                                : Text("Rejected",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ))
                          ],
                        ),
                      )
                : Container(),
          ],
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
