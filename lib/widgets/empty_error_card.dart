import 'package:flutter/material.dart';


class CustomEmptyErrorCard extends StatelessWidget {
  final String errorMsg;
  TextStyle errorTestStyle;

  CustomEmptyErrorCard({
    @required this.errorMsg,
    @required this.errorTestStyle,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 10,
          bottom: 10,
        ),
        margin: EdgeInsets.only(
          top: 60,
          left: 10,
          right: 10,
          bottom: 60,
        ),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)],
            borderRadius: BorderRadius.all(Radius.circular(5))),
        child: Text(
          errorMsg,
          textAlign: TextAlign.center,
          style: errorTestStyle,
        ),
      ),
    );
  }
}
