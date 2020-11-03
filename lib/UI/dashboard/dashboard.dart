import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:krish_connect/UI/dashboard/dashboardScreen.dart';
import 'package:krish_connect/UI/requestsStudent.dart';
import 'package:krish_connect/data/student.dart';
import 'package:krish_connect/main.dart';
import 'package:krish_connect/service/database.dart';
import 'package:krish_connect/widgets/appBackground.dart';
import 'package:krish_connect/widgets/columnBuilder.dart';
import 'package:krish_connect/widgets/customExpandableTile.dart';
import 'package:provider/provider.dart';

class DashBoard extends StatefulWidget {
  @override
  _DashBoardState createState() => _DashBoardState();
}

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
    // TODO: implement initState
    super.initState();
    currentIndex = 0;
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
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0.5).animate(
          CurvedAnimation(parent: _controller, curve: Curves.elasticOut)),
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: GestureDetector(
            onPanUpdate: (details) {
              //on swiping left
              if (details.delta.dx < -6) {
                if (_controller.status == AnimationStatus.completed) {
                  Provider.of<AnimationProvider>(context, listen: true)
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
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              child: Scaffold(
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8),
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
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: 0.24 * screenHeight,
                              child: Swiper(
                                onTap: (int index) {},
                                onIndexChanged: (int index) {},
                                layout: SwiperLayout.STACK,
                                itemCount: 5,
                                itemWidth: 0.8 * screenWidth,
                                itemBuilder: (context, int index) {
                                  return Card(
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: Container(
                                      width: 0.8 * screenWidth,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 12.0,
                                                  top: 18,
                                                ),
                                                child: Text(
                                                  "Ms Gwen Stacy",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12.0,
                                                ),
                                                child: Text(
                                                  "Oct 31 11:15 pm",
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12.0),
                                              child: Text(
                                                "Dear Students, K12 Techno Services presents Hack-ED v1.0, inviting all developers and hackathon enthusiasts to come up with fantastic ideas to build products from scratch. Code your way from backend to frontend and design products that are unique, valuable, and user friendly!",
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Flexible(
                                                  child: IconButton(
                                                    tooltip:
                                                        "Positive Response",
                                                    icon: FaIcon(
                                                      FontAwesomeIcons.check,
                                                      color: Colors.green,
                                                      size: 20,
                                                    ),
                                                    onPressed: () {},
                                                  ),
                                                ),
                                                Flexible(
                                                  child: IconButton(
                                                    tooltip: "Noted",
                                                    icon: FaIcon(
                                                      FontAwesomeIcons.bookmark,
                                                      color: Colors.yellow[900],
                                                      size: 20,
                                                    ),
                                                    onPressed: () {},
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
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
                                              child:
                                                  CircularProgressIndicator(),
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
                                              itemBuilder:
                                                  (context, int index) {
                                                return Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
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
                                                        return Future.value(
                                                            true);
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
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
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
      ),
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
