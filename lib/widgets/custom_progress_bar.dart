import 'package:dragnet/widgets/loading_overlay.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomProgressBar extends StatelessWidget {
  final bool isLoading;
  final Widget widget;

  CustomProgressBar({
    @required this.isLoading,
    @required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return LoadingOverlay(
      opacity: 1,
      color: Colors.white12,
      isLoading: isLoading,
      progressIndicator: CupertinoActivityIndicator(
        radius: 15,
        animating: true,
      ),
      child: widget,
    );
  }
}
