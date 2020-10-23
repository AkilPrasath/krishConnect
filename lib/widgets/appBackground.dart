import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({
    Key key,
    @required this.child,
    @required this.screenWidth,
    @required this.screenHeight,
  }) : super(key: key);

  final double screenWidth;
  final double screenHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: screenWidth,
      height: screenHeight,
      child: Stack(
        children: [
          Positioned(
            right: -0.1 * screenWidth,
            top: 0.15 * screenHeight,
            child: Stack(
              overflow: Overflow.visible,
              alignment: Alignment.center,
              children: [
                Container(
                  width: 0.63 * screenWidth,
                  height: 0.63 * screenWidth,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xff5EC4EA).withOpacity(0.8),
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 0.6 * screenWidth,
                  height: 0.6 * screenWidth,
                  decoration: BoxDecoration(
                    color: Colors.blue[300],
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: -0.1 * screenWidth,
            bottom: 0.2 * screenHeight,
            child: Container(
              width: 0.5 * screenWidth,
              height: 0.5 * screenWidth,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xff5EC4EA).withOpacity(0.5),
              ),
            ),
          ),
          Positioned(
            right: -0.1 * screenWidth,
            bottom: -0.15 * screenHeight,
            child: Container(
              width: 0.8 * screenWidth,
              height: 0.8 * screenWidth,
              decoration: BoxDecoration(
                color: Color(0xff5EC4EA).withOpacity(0.9),
                shape: BoxShape.circle,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
