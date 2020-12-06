import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:krish_connect/data/staff.dart';
import 'package:krish_connect/main.dart';
import 'package:krish_connect/service/staffDatabase.dart';
import 'package:krish_connect/widgets/columnBuilder.dart';
import 'package:linkwell/linkwell.dart';
import 'package:logger/logger.dart';

class AnnouncementListStaff extends StatefulWidget {
  Staff staff;
  AnnouncementListStaff({@required this.staff});
  @override
  _AnnouncementListStaffState createState() => _AnnouncementListStaffState();
}

class _AnnouncementListStaffState extends State<AnnouncementListStaff> {
  double screenHeight;
  double screenWidth;
  List classList;
  int selectedClassIndex = -1;
  int selectedCardIndex = -1;
  @override
  void initState() {
    super.initState();
    classList = widget.staff.subjects
        .toList(); //never use just subjects as it returns the reference which is dangerous!!
    Map tutorMap = widget.staff.tutor;
    if (tutorMap != null) {
      bool toAdd = true;
      for (dynamic subMap in classList) {
        if (mapEquals(tutorMap, subMap)) {
          toAdd = false;
          break;
        }
      }
      if (toAdd) {
        classList.add(tutorMap);
      }
    }
  }

  // List<String> getClassList() {
  //   List<String> sub = [];
  //   Staff staff = widget.staff;
  //   for (dynamic subjectMap in staff.subjects) {
  //     String sem = subjectMap["semester"].toString();
  //     String dep = subjectMap["department"].toString();
  //     String sec = subjectMap["section"].toString();
  //     sub.add(sem+" "+dep+" "+)
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth,
      height: screenHeight,
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: ColumnBuilder(
          mainAxisSize: MainAxisSize.min,
          itemCount: classList.length,
          itemBuilder: (context, classIndex) {
            return Column(
              children: [
                RichText(
                  text: TextSpan(
                    text: classList[classIndex]["department"] + " ",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(
                        text: classList[classIndex]["section"] + " ",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: "Semester " +
                            classList[classIndex]["semester"].toString(),
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                StreamBuilder(
                  stream: getIt<StaffDatabase>().getAnnouncementStream(
                      subjectMap: classList[classIndex], staff: widget.staff),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ColumnBuilder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, cardIndex) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (selectedClassIndex == classIndex &&
                                      selectedCardIndex == cardIndex) {
                                    selectedClassIndex = -1;
                                    selectedCardIndex = -1;
                                  } else {
                                    selectedClassIndex = classIndex;
                                    selectedCardIndex = cardIndex;
                                  }
                                });
                              },
                              child: AnimatedAnnouncementCard(
                                announcementMap: snapshot.data[cardIndex],
                                resized: selectedClassIndex == classIndex &&
                                    selectedCardIndex == cardIndex,
                              ),
                            );
                          });
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                  child: Divider(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class AnimatedAnnouncementCard extends StatelessWidget {
  double screenWidth, screenHeight;
  bool resized;

  String relativeTime;
  Map<String, dynamic> announcementMap;

  AnimatedAnnouncementCard({
    @required this.resized,
    @required this.announcementMap,
  }) {
    relativeTime = Jiffy(announcementMap["timestamp"].toDate()).fromNow();
  }
  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: 0.9 * screenWidth,
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
          ],
        ),
      ),
    );
  }
}
