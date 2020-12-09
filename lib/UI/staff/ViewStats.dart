import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:krish_connect/main.dart';
import 'package:krish_connect/service/staffDatabase.dart';
import 'package:krish_connect/widgets/columnBuilder.dart';
import 'package:linkwell/linkwell.dart';
import 'package:logger/logger.dart';

class ViewStats extends StatefulWidget {
  final Map classNameMap;
  final Map<String, dynamic> announcementMap;
  ViewStats({@required this.announcementMap, @required this.classNameMap});
  @override
  _ViewStatsState createState() => _ViewStatsState();
}

class _ViewStatsState extends State<ViewStats> {
  Map<String, dynamic> announcementMap;
  String relativeTime;
  String className;
  int selected = 1;
  double screenHeight, screenWidth;
  int respondedYesCount, respondedNoCount, respondedNoneCount;
  Map responseMap;
  Map allStudentsMap;
  List respondedRollNoList;
  int totalRollNo;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    allStudentsMap = {};
    className = widget.classNameMap["semester"].toString() +
        widget.classNameMap["department"] +
        widget.classNameMap["section"]; //1CSE

    updateResponseData(widget.announcementMap);
    relativeTime = Jiffy(announcementMap["timestamp"].toDate()).fromNow();
  }

  updateResponseData(Map updatedAnnouncementMap) {
    announcementMap = updatedAnnouncementMap;

    respondedNoCount = respondedYesCount = respondedNoneCount = 0;
    responseMap = announcementMap["response"];
    respondedRollNoList = responseMap.keys.toList();
    respondedRollNoList.forEach((rollNo) {
      if (responseMap[rollNo] == true) {
        respondedYesCount += 1;
      } else {
        respondedNoCount += 1;
      }
    });
  }

  int getcurrentAnnouncementIndex(List announcementMapList) {
    for (int i = 0; i < announcementMapList.length; i++) {
      if ((announcementMapList[i]["name"].keys.toList()[0] ==
              announcementMap["name"].keys.toList()[0]) &&
          (announcementMapList[i]["timestamp"] ==
              announcementMap["timestamp"])) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: FittedBox(
              child: Text(
            "Announcement Stats",
            style: TextStyle(color: Colors.blue[400]),
          )),
          leading: FittedBox(
            child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.chevron_left,
                    color: Colors.blue[400],
                  ),
                )),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: <Widget>[
                Card(
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
                                  announcementMap["priority"] == 0
                                      ? "Neutral"
                                      : 'High',
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
                      SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(right: 20, left: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "$relativeTime",
                              style: TextStyle(
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              announcementMap["type"],
                              style: TextStyle(
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Padding(
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
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                StreamBuilder<DocumentSnapshot>(
                  stream: getIt<StaffDatabase>().responseStatStream(className),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      int currentAnnouncementIndex =
                          getcurrentAnnouncementIndex(
                              snapshot.data.data()["announcements"]);

                      updateResponseData(snapshot.data.data()["announcements"]
                          [currentAnnouncementIndex]);

                      return StreamBuilder(
                        stream: getIt<StaffDatabase>()
                            .classStudentsCountStream(className),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            totalRollNo = snapshot.data["count"];
                            allStudentsMap = snapshot.data["roll-name"];

                            respondedNoneCount = totalRollNo -
                                (respondedYesCount + respondedNoCount);

                            return Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8.0),
                                    child: Text(
                                      "Visual Stats",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: screenWidth,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                PieChart(
                                                  PieChartData(
                                                    borderData: FlBorderData(
                                                      show: false,
                                                    ),
                                                    sections: [
                                                      PieChartSectionData(
                                                        showTitle:
                                                            respondedYesCount !=
                                                                0,
                                                        title: respondedYesCount
                                                            .toString(),
                                                        value:
                                                            (respondedYesCount /
                                                                    totalRollNo)
                                                                .toDouble(),
                                                        color: Colors.teal,
                                                      ),
                                                      PieChartSectionData(
                                                        showTitle:
                                                            respondedNoCount !=
                                                                0,
                                                        title: respondedNoCount
                                                            .toString(),
                                                        value:
                                                            (respondedNoCount /
                                                                    totalRollNo)
                                                                .toDouble(),
                                                        color: Colors.orange,
                                                      ),
                                                      PieChartSectionData(
                                                        showTitle:
                                                            respondedNoneCount !=
                                                                0,
                                                        title:
                                                            respondedNoneCount
                                                                .toString(),
                                                        value:
                                                            (respondedNoneCount /
                                                                    totalRollNo)
                                                                .toDouble(),
                                                        color: Colors.blue,
                                                      ),
                                                    ],
                                                  ),
                                                  swapAnimationDuration:
                                                      Duration(
                                                          milliseconds: 400),
                                                ),
                                                Center(
                                                  child: Text(
                                                      "Total Students: " +
                                                          totalRollNo
                                                              .toString()),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 16.0,
                                                      vertical: 4),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.teal,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(3),
                                                        ),
                                                        width: 20,
                                                        height: 20,
                                                      ),
                                                      SizedBox(width: 8),
                                                      announcementMap["type"] ==
                                                              "yesorno"
                                                          ? Text(
                                                              "Responded Yes")
                                                          : Text("Seen"),
                                                    ],
                                                  ),
                                                ),
                                                announcementMap["type"] ==
                                                        "yesorno"
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal:
                                                                    16.0,
                                                                vertical: 4),
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .orange,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            3),
                                                              ),
                                                              width: 20,
                                                              height: 20,
                                                            ),
                                                            SizedBox(width: 8),
                                                            Text(
                                                                "Responded No"),
                                                          ],
                                                        ),
                                                      )
                                                    : SizedBox(),
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 16.0,
                                                      vertical: 4),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.blue,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(3),
                                                        ),
                                                        width: 20,
                                                        height: 20,
                                                      ),
                                                      SizedBox(width: 8),
                                                      announcementMap["type"] ==
                                                              "yesorno"
                                                          ? Text(
                                                              "Yet to Respond")
                                                          : Text("Not Seen"),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8.0),
                                    child: Text(
                                      "People",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                                Card(
                                  child: Container(
                                    width: screenWidth,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Expanded(
                                              child: Material(
                                                color: selected == 1
                                                    ? Colors.green
                                                    : Colors.green[200],
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      selected = 1;
                                                    });
                                                  },
                                                  child: Center(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        "Yes",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            announcementMap["type"] == "yesorno"
                                                ? Expanded(
                                                    child: Material(
                                                      color: selected == 2
                                                          ? Colors.orange
                                                          : Colors.orange[200],
                                                      child: InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            selected = 2;
                                                          });
                                                        },
                                                        child: Center(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text(
                                                              "No",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : SizedBox(),
                                            Expanded(
                                              flex: 2,
                                              child: Material(
                                                color: selected == 3
                                                    ? Colors.blue
                                                    : Colors.blue[200],
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      selected = 3;
                                                    });
                                                  },
                                                  child: Center(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        "Yet to Respond",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        AnimatedSwitcher(
                                          duration: Duration(milliseconds: 300),
                                          child: Padding(
                                            key: UniqueKey(),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16.0),
                                            child: ColumnBuilder(
                                                itemBuilder: (context, index) {
                                                  List rollNoList =
                                                      allStudentsMap.keys
                                                          .toList();
                                                  rollNoList.sort();
                                                  if (responseMap[rollNoList[
                                                              index]] ==
                                                          true &&
                                                      selected == 1) {
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 8.0,
                                                          horizontal: 8),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Text(allStudentsMap[
                                                              rollNoList[
                                                                  index]]),
                                                          Spacer(),
                                                          Text(rollNoList[
                                                              index]),
                                                        ],
                                                      ),
                                                    );
                                                  } else if (responseMap[
                                                              rollNoList[
                                                                  index]] ==
                                                          false &&
                                                      selected == 2) {
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 8.0,
                                                          horizontal: 8),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Text(allStudentsMap[
                                                              rollNoList[
                                                                  index]]),
                                                          Spacer(),
                                                          Text(rollNoList[
                                                              index]),
                                                        ],
                                                      ),
                                                    );
                                                  } else if (selected == 3 &&
                                                      responseMap[rollNoList[
                                                              index]] ==
                                                          null) {
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 8.0,
                                                          horizontal: 16),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Text(allStudentsMap[
                                                              rollNoList[
                                                                  index]]),
                                                          Spacer(),
                                                          Text(rollNoList[
                                                              index]),
                                                        ],
                                                      ),
                                                    );
                                                  } else {
                                                    return Container();
                                                  }
                                                },
                                                itemCount: allStudentsMap.keys
                                                    .toList()
                                                    .length),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        },
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
