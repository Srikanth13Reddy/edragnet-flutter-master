import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ChapterDetailsPage extends StatefulWidget {
  @override
  _ChapterDetailsPageState createState() => _ChapterDetailsPageState();
}

class _ChapterDetailsPageState extends State<ChapterDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(243, 245, 249, 1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.fromRGBO(243, 245, 249, 1),
        iconTheme: IconThemeData(
          color: Color.fromRGBO(69, 79, 99, 1),
        ),
        title: Text(
          "Course details",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Color.fromRGBO(69, 79, 99, 1),
          ),
        ),
      ),
      body: _body(),
    );
  }

  final List<String> entries = <String>[
    'Approach',
    'Engine Compartment',
    'Walk Around',
    "Practice Test",
  ];
  final List<String> subEntries = <String>[
    '4 of 8 lessons',
    '4 of 8 lessons',
    '4 of 8 lessons',
    "25 Questions",
  ];
  final List<int> status = <int>[
    0,
    1,
    1,
    2,
  ];
  Widget _body() {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: Colors.white,
          )),
      margin: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Center(
              child: Text(
                "CDL Class A Modified",
                style: GoogleFonts.poppins(
                  color: Color.fromRGBO(78, 78, 78, 1),
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Center(
              child: Text(
                "6 Chapter, 120 Lessons",
                style: GoogleFonts.poppins(
                  color: Color.fromRGBO(255, 137, 13, 1),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 15),
              child: Text(
                "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
                style: GoogleFonts.poppins(
                  color: Color.fromRGBO(167, 165, 165, 1),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Chapter",
              style: GoogleFonts.poppins(
                color: Color.fromRGBO(255, 137, 13, 1),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Expanded(
              child: ListView.builder(
                  padding: const EdgeInsets.only(left: 20, top: 10),
                  itemCount: entries.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      margin: EdgeInsets.only(right: 20),
                      height: 80,
                      child: Row(
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Expanded(
                                child: VerticalDivider(
                                  thickness: 2,
                                  color: Colors.black12,
                                ),
                              ),
                              SizedBox(
                                height: 3,
                              ),
                              getStatusIcon(status[index]),
                              SizedBox(
                                height: 3,
                              ),
                              Expanded(
                                child: VerticalDivider(
                                  thickness: 2,
                                  color: Colors.black12,
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                              child: Card(
                            elevation: 5,
                            color: Color.fromRGBO(245, 245, 245, 1),
                            margin: EdgeInsets.only(left: 20, top: 10),
                            child: Padding(
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          '${entries[index]}',
                                          style: GoogleFonts.poppins(
                                            color: Colors.black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        Text(
                                          '${subEntries[index]}',
                                          style: GoogleFonts.poppins(
                                            color: Color.fromRGBO(
                                                131, 131, 131, 1),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  LinearPercentIndicator(
                                    width: 80.0,
                                    lineHeight: 06.0,
                                    percent: 0.5,
                                    animation: true,
                                    backgroundColor: Colors.grey,
                                    progressColor:
                                        Color.fromRGBO(255, 137, 13, 1),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.only(
                                  left: 20, top: 10, bottom: 10),
                            ),
                          )),
                        ],
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Icon getStatusIcon(int status) {
    if (status == 0) {
      return Icon(
        FontAwesomeIcons.check,
        size: 15,
        color: Color.fromRGBO(255, 137, 13, 1),
      );
    } else if (status == 1) {
      return Icon(
        FontAwesomeIcons.solidCircle,
        size: 15,
        color: Color.fromRGBO(255, 137, 13, 1),
      );
    } else {
      return Icon(
        FontAwesomeIcons.solidCircle,
        size: 15,
        color: Colors.black26,
      );
    }
  }
}
