import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomExpandableListTile extends StatelessWidget {
  const CustomExpandableListTile({
    Key key,
  }) : super(key: key);

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
          "OD",
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        title: Text("Project"),
        subtitle: Row(
          children: [
            FaIcon(
              FontAwesomeIcons.checkCircle,
              color: Colors.green,
              size: 15,
            ),
            Text("  Granted"),
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
                        Text(
                          "Oct 31 - Nov 2",
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
                        Text(
                          "Ms A Priya",
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
                            "I'm doing my project works for XYZ company, So please grant me on duty for 3 days.",
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
