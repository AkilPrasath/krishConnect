import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:krish_connect/UI/login.dart';
import 'package:krish_connect/UI/staff/dashboard/staff_dashboard_screen.dart';
import 'package:krish_connect/UI/staff/post_announcements.dart';
import 'package:krish_connect/UI/staff/viewAllRequestsPage.dart';

import 'package:krish_connect/data/staff.dart';
import 'package:krish_connect/main.dart';
import 'package:krish_connect/service/authentication.dart';

import 'package:provider/provider.dart';

class StaffDrawerMenu extends StatefulWidget {
  static final String id = "Drawer menu";
  @override
  _StaffDrawerMenuState createState() => _StaffDrawerMenuState();
}

class _StaffDrawerMenuState extends State<StaffDrawerMenu> {
  double width;
  double height;
  double imageWidth;
  double imageHeight;
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onPanUpdate: (details) {
        //on swiping left
        AnimationController _controller =
            Provider.of<StaffDrawerAnimationProvider>(context, listen: true)
                .controller;
        if (details.delta.dx < -6) {
          if (_controller.status == AnimationStatus.completed) {
            _controller.reverse();
          }
        }
      },
      child: Scaffold(
        body: Container(
          width: 0.8 * width,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                // height: 0.3 * height,
                child: Stack(
                  children: [
                    Container(
                      width: 0.8 * width,
                      height: 0.15 * height,
                      constraints: BoxConstraints(
                        minWidth: 0.8 * width,
                      ),
                      child: Image.asset(
                        "assets/images/abstract.jpg",
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      width: 0.8 * width,
                      height: 0.15 * height,
                      color: Colors.white12,
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: 0.08 * height,
                          ),
                          Container(
                            height: 0.25 * width,
                            width: 0.25 * width,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage(
                                  "assets/images/circleAvatar.png",
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "Akil Stark",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "CSE",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 0.04 * height,
              ),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    DrawerItem(
                      iconData: FontAwesomeIcons.bullhorn,
                      text: "Announcements",
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PostAnnouncementPage()));
                      },
                    ),
                    DrawerItem(
                      iconData: FontAwesomeIcons.fileImport,
                      text: "Review Requests",
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ViewAllRequestsPage()));
                      },
                    ),
                    DrawerItem(
                      iconData: FontAwesomeIcons.cog,
                      text: "Settings",
                    ),
                    DrawerItem(
                      iconData: FontAwesomeIcons.infoCircle,
                      text: "About",
                    ),
                  ],
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Spacer(),
                    InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () async {
                        Staff staff = await getIt.getAsync<Staff>();
                        staff.clearData();
                        await getIt<Authentication>().logoutUser();

                        Navigator.pushReplacementNamed(context, LoginScreen.id);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: FaIcon(
                                FontAwesomeIcons.powerOff,
                                color: Colors.redAccent,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 4, 4, 4),
                              child: Text(
                                " Log out",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  const DrawerItem({
    @required this.iconData,
    @required this.text,
    this.onTap,
    Key key,
  }) : super(key: key);

  final String text;
  final IconData iconData;
  final Function onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4),
        child: ListTile(
          visualDensity: VisualDensity(horizontal: 0, vertical: -4),
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            iconData,
            color: Colors.grey[800],
            size: 20,
          ),
          title: Text(
            "$text",
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
