import 'package:dragnet/utils/colors.dart';
import 'package:dragnet/utils/constants.dart';
import 'package:flutter/material.dart';

class CustomProfileImage extends StatelessWidget {
  final String url;
  final double radius;

  CustomProfileImage({
    @required this.url,
    @required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    print("url $url");
    if (url != "" && url != null) {
      precacheImage(NetworkImage(url), context);
    }
    // TODO: implement build
    return CircleAvatar(
      backgroundColor: BorderColor,
      backgroundImage:
          url == "" || url == null ? PlaceholderImage : NetworkImage(url),
      radius: radius,
    );
  }
}
