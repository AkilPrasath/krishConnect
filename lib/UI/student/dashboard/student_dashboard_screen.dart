import 'package:flutter/material.dart';
import 'package:krish_connect/UI/student/dashboard/student_dashboard.dart';
import 'package:krish_connect/UI/student/dashboard/student_drawer_menu.dart';
import 'package:krish_connect/widgets/appBackground.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  static final String id = "Dashboard Screen";
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  double screenHeight;
  double screenWidth;

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        body: ChangeNotifierProvider(
          builder: (context) => AnimationProvider(vsync: this),
          child: AppBackground(
            screenHeight: screenHeight,
            screenWidth: screenWidth,
            child: Stack(
              children: [
                DrawerMenu(),
                DashBoard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimationProvider with ChangeNotifier {
  AnimationController controller;
  TickerProvider vsync;
  AnimationProvider({@required this.vsync}) {
    controller = AnimationController(
        vsync: vsync, duration: Duration(milliseconds: 300));
    controller.addListener(() {
      notifyListeners();
    });
  }
  open() {
    controller.forward();
  }

  close() {
    controller.reverse();
  }

  toggle() {
    if (controller.status == AnimationStatus.completed) {
      close();
    } else if (controller.status == AnimationStatus.dismissed) {
      open();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    controller.dispose();
  }
}
