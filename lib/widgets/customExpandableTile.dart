import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';

class CustomExpandableListTile extends StatelessWidget {
  const CustomExpandableListTile({Key key, this.studentMap}) : super(key: key);
  final Map<String, dynamic> studentMap;

  TextStyle _headingStyle() {
    return GoogleFonts.workSans(
      fontWeight: FontWeight.w700,
      color: Colors.grey[850],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: Text(
          "${studentMap["type"]}",
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text("${Jiffy(studentMap["timestamp"].toDate()).fromNow()}"),
        ),
        subtitle: Row(
          children: [
            studentMap["response"] == 0
                ? FaIcon(
                    FontAwesomeIcons.hourglass,
                    size: 15,
                    color: Colors.amber,
                  )
                : (studentMap["response"] == 1)
                    ? FaIcon(
                        FontAwesomeIcons.solidCheckCircle,
                        size: 15,
                        color: Colors.green,
                      )
                    : FaIcon(
                        FontAwesomeIcons.ban,
                        size: 15,
                        color: Colors.red,
                      ),
            studentMap["response"] == 0
                ? Text("  Pending")
                : (studentMap["response"] == 1)
                    ? Text("  Accepted")
                    : Text("  Rejected"),
          ],
        ),
        onExpansionChanged: (isExpanded) {},
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4),
                    child: Row(
                      children: [
                        Text(
                          "Duration     :  ",
                          style: _headingStyle(),
                        ),
                        Flexible(
                          child: Text(
                            "${studentMap["date"]}",
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4),
                    child: Row(
                      children: [
                        Text(
                          "Addressed  :  ",
                          style: _headingStyle(),
                        ),
                        Flexible(
                          child: Text(
                            "${studentMap["addressed"]}",
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Reason        :  ",
                          style: _headingStyle(),
                        ),
                        Flexible(
                          child: Text(
                            "${studentMap["body"]}",
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
