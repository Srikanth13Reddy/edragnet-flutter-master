import 'package:dragnet/utils/colors.dart';
import 'package:dragnet/widgets/bubble.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//Chat message Style
final msgStyleSomebody = BubbleStyle(
  nip: BubbleNip.leftTop,
  color: Colors.white,
  elevation: 1,
  margin: BubbleEdges.only(top: 8.0, right: 50.0),
  alignment: Alignment.topLeft,
);

final msgStyleMe = BubbleStyle(
  nip: BubbleNip.rightTop,
  color: Color.fromARGB(255, 225, 255, 199),
  elevation: 1,
  margin: BubbleEdges.only(top: 8.0, left: 50.0),
  alignment: Alignment.topRight,
);

final msgNameTextStyle = GoogleFonts.sourceSansPro(
  fontSize: 17,
  color: Color.fromRGBO(36, 36, 36, 1),
  fontWeight: FontSemiBold,
);

final msgTextStyle = GoogleFonts.sourceSansPro(
  fontSize: 14,
  color: MediumGreyColor,
  fontWeight: FontRegular,
);

final msgTimeTextStyle = GoogleFonts.rubik(
  fontSize: 10,
  color: BorderColor,
  fontWeight: FontRegular,
);

final titleTextStyleBlack = GoogleFonts.sourceSansPro(
  fontSize: 26,
  color: BlackColor,
  fontWeight: FontBold,
);

final subTitleTextStyleGrey = GoogleFonts.sourceSansPro(
  fontSize: 14,
  color: MediumGreyColor,
  fontWeight: FontRegular,
);

final subTitleTextStyleBlue = GoogleFonts.sourceSansPro(
  fontSize: 14,
  color: BlueColor,
  fontWeight: FontMedium,
);

final btnTextStyleWhite = GoogleFonts.sourceSansPro(
  fontSize: 15,
  color: Colors.white,
  fontWeight: FontMedium,
);

final btnTextStyleWhiteBold = GoogleFonts.sourceSansPro(
  fontSize: 15,
  color: Colors.white,
  fontWeight: FontSemiBold,
);

final btnTextStyleGrey = GoogleFonts.sourceSansPro(
  fontSize: 14,
  color: DarkGreyColor,
  fontWeight: FontMedium,
);

final menuTextStyle = GoogleFonts.sourceSansPro(
  fontSize: 15,
  color: DarkTextColor,
  fontWeight: FontSemiBold,
);

final textStyleBlue = GoogleFonts.sourceSansPro(
  fontSize: 15,
  color: BlueColor,
  fontWeight: FontSemiBold,
);

final appBarTitleTextStyle = GoogleFonts.sourceSansPro(
  color: DarkTextColor,
  fontSize: 22,
  fontWeight: FontBold,
);

final profileTextStyle = GoogleFonts.sourceSansPro(
  color: ProfileTextColor,
  fontSize: 14,
  fontWeight: FontMedium,
);

final textBoxTextStyleBlack = GoogleFonts.sourceSansPro(
  fontSize: 15,
  color: BlackColor,
  fontWeight: FontMedium,
);
final textStyleBlackBold = GoogleFonts.sourceSansPro(
  fontSize: 14,
  color: BlackColor,
  fontWeight: FontSemiBold,
);

final textBoxTextStyleGrey = GoogleFonts.sourceSansPro(
  fontSize: 14,
  color: MediumGreyColor,
  fontWeight: FontMedium,
);

final textBoxHintTextStyle = GoogleFonts.sourceSansPro(
  fontSize: 14,
  color: MediumGreyColor,
  fontWeight: FontRegular,
);
final textBoxHintTextStyle2 = GoogleFonts.sourceSansPro(
  fontSize: 14,
  color: Colors.black,
  fontWeight: FontRegular,
);

final textBoxErrorTextStyle = GoogleFonts.sourceSansPro(
  color: Colors.red,
  fontSize: 12,
);

final notificationTimeTextStyle = GoogleFonts.sourceSansPro(
  fontSize: 12,
  color: MediumGreyColor,
  fontWeight: FontRegular,
);

final textBoxEnabledUnderlineDecoration = UnderlineInputBorder(
  borderSide: BorderSide(color: AshColor),
  borderRadius: BorderRadius.all(Radius.circular(6)),
);

final textBoxFocusedUnderlineDecoration = UnderlineInputBorder(
  borderSide: BorderSide(color: AshColor),
  borderRadius: BorderRadius.all(Radius.circular(6)),
);

final errorBorderStyle = OutlineInputBorder(
  borderSide: BorderSide(color: Colors.red),
  borderRadius: BorderRadius.all(Radius.circular(6)),
);
