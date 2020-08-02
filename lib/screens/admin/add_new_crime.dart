import 'package:dragnet/utils/Utility.dart';
import 'package:dragnet/utils/colors.dart';
import 'package:dragnet/utils/custom_textstyles.dart';
import 'package:dragnet/widgets/custom_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class AddNewCrime extends StatefulWidget {
  @override
  _AddNewCrimeState createState() => _AddNewCrimeState();
}

class _AddNewCrimeState extends State<AddNewCrime> {
  bool _isLoading=false;
  var _formKey = GlobalKey<FormState>();
  TextEditingController crimeNameController = TextEditingController();
  TextEditingController requester_infoController = TextEditingController();
  TextEditingController accurance_Controller = TextEditingController();
  TextEditingController accurance_time_Controller = TextEditingController();
  TextEditingController severity_Controller = TextEditingController();
  TextEditingController status_Controller = TextEditingController();



  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.dark,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('Add New Crime',style: GoogleFonts.poppins(
          fontSize: 18,
          color: Colors.black
        ),),
      ),
      body: CustomProgressBar(
        isLoading: _isLoading,
        widget: loginCard(context),
      ),
    );
  }

  Widget loginCard(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.only(left: 30, right: 30),
        children: <Widget>[

          SizedBox(
            height: 3,
          ),
          SizedBox(
            height: 35,
          ),
          _crimeNameTextField(),
          SizedBox(
            height: 24,
          ),
          _requester_infoTextField(),
          SizedBox(
            height: 24,
          ),
          _chooseaccuranceTextField()
,
          SizedBox(
            height: 24,
          ),
          _occurance_timeTextField(),
          SizedBox(
            height: 24,
          ),
          _severity_TextField(),
          SizedBox(
            height: 24,
          ),
          _status_TextField(),
          SizedBox(
            height: 24,
          ),
          _selectLocationButton()
        ],
      ),
    );
  }


  Widget _crimeNameTextField() {
    var crimename = TextFormField(
      style: textBoxTextStyleBlack,
      controller: crimeNameController,
      validator: (String value) {
        if (value.isEmpty) {
          return "Empty Crime Name";
        } else {
          return null;
        }
      },
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          filled: true,
          fillColor: AshColor,
          hintText:"Crime Name",
          hintStyle: textBoxHintTextStyle2,
          enabledBorder: textBoxEnabledUnderlineDecoration,
          focusedBorder: textBoxFocusedUnderlineDecoration,
          errorStyle: textBoxErrorTextStyle),
    );
    return Card(
      elevation: 5,
      child: crimename,
    );
  }

  _requester_infoTextField()
  {
    var requester_info = TextFormField(
      style: textBoxTextStyleBlack,
      controller: requester_infoController,
      validator: (String value) {
        if (value.isEmpty) {
          return "Empty Requester Information";
        } else {
          return null;
        }
      },
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          filled: true,
          fillColor: AshColor,
          hintText:"Requester Information",
          hintStyle: textBoxHintTextStyle2,
          enabledBorder: textBoxEnabledUnderlineDecoration,
          focusedBorder: textBoxFocusedUnderlineDecoration,
          errorStyle: textBoxErrorTextStyle),
    );
    return Card(
      elevation: 5,
      child: requester_info,
    );
  }

  _chooseaccuranceTextField()
  {
    var requester_info = TextFormField(
      style: textBoxTextStyleBlack,
      controller: accurance_Controller,
      validator: (String value) {
        if (value.isEmpty) {
          return "Empty Occurance";
        } else {
          return null;
        }
      },
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          filled: true,
          fillColor: AshColor,
          hintText:"Choose Occurance",
          hintStyle: textBoxHintTextStyle2,
          enabledBorder: textBoxEnabledUnderlineDecoration,
          focusedBorder: textBoxFocusedUnderlineDecoration,
          errorStyle: textBoxErrorTextStyle),
    );
    return Card(
      elevation: 5,
      child: requester_info,
    );
  }

  _occurance_timeTextField()
  {
    var requester_info = TextFormField(
      style: textBoxTextStyleBlack,
      controller: accurance_time_Controller,
      validator: (String value) {
        if (value.isEmpty) {
          return "Empty Occurance Time";
        } else {
          return null;
        }
      },
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          filled: true,
          fillColor: AshColor,
          hintText:"Occurance Time",
          hintStyle: textBoxHintTextStyle2,
          enabledBorder: textBoxEnabledUnderlineDecoration,
          focusedBorder: textBoxFocusedUnderlineDecoration,
          errorStyle: textBoxErrorTextStyle),
    );
    return Card(
      elevation: 5,
      child: requester_info,
    );
  }

  _severity_TextField()
  {
    var requester_info = TextFormField(
      style: textBoxTextStyleBlack,
      controller: severity_Controller,
      validator: (String value) {
        if (value.isEmpty) {
          return "Empty Severity";
        } else {
          return null;
        }
      },
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          filled: true,
          fillColor: AshColor,
          hintText:"Severity",
          hintStyle: textBoxHintTextStyle2,
          enabledBorder: textBoxEnabledUnderlineDecoration,
          focusedBorder: textBoxFocusedUnderlineDecoration,
          errorStyle: textBoxErrorTextStyle),
    );
    return Card(
      elevation: 5,
      child: requester_info,
    );
  }

  _status_TextField()
  {
    var requester_info = TextFormField(
      style: textBoxTextStyleBlack,
      controller: status_Controller,
      validator: (String value) {
        if (value.isEmpty) {
          return "Empty Status";
        } else {
          return null;
        }
      },
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          filled: true,
          fillColor: AshColor,
          hintText:"Status",
          hintStyle: textBoxHintTextStyle2,
          enabledBorder: textBoxEnabledUnderlineDecoration,
          focusedBorder: textBoxFocusedUnderlineDecoration,
          errorStyle: textBoxErrorTextStyle),
    );
    return Card(
      elevation: 5,
      child: requester_info,
    );
  }

  Widget _selectLocationButton() {
    var loginBtn = Padding(
      padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
      child: SizedBox(
        width: double.infinity,
        height: 45.0,
        child: new RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          padding: const EdgeInsets.all(10.0),
          color: DarkBlueColor,
          textColor: Colors.white,
          child: Text("Select Location",
              textScaleFactor: 1.15, style: btnTextStyleWhite),
          onPressed: () {

          },
        ),
      ),
    );
    return loginBtn;
  }
}
