import 'dart:async';

import 'package:dragnet/models/responses/createmarkerdetails_model.dart';
import 'package:dragnet/services/api_services.dart';
import 'package:dragnet/services/backen_service.dart';
import 'package:dragnet/utils/Utility.dart';
import 'package:dragnet/utils/colors.dart';
import 'package:dragnet/utils/constants.dart';
import 'package:dragnet/utils/custom_textstyles.dart';
import 'package:dragnet/utils/service_urls.dart';
import 'package:dragnet/widgets/custom_progress_bar.dart';
import 'package:dragnet/widgets/flutter_time_picker_spinner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class CrimeTagPage extends StatefulWidget {
  final String userId;
  final String notificationId;
  final String crimeId;
  final String crimedescription;
  CrimeTagPage(
      {Key key,
      this.userId,
      this.notificationId,
      this.crimeId,
      this.crimedescription})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CrimeTagState();
  }
}

class CrimeTagState extends State<CrimeTagPage> {
  String _userId;
  String _notificationId;
  String _crimeId;
  String _crimeDescription;
  TextEditingController _commentsController = TextEditingController();
  TextEditingController _whenController = TextEditingController();
  TextEditingController _whereController = TextEditingController();
  DateTime _timeOfDay;
  String _searchAddress;
  String _currentAddress;
  final Geolocator _geoLocator = Geolocator()..forceAndroidLocationManager;
  Position _currentPosition;
  LatLng _updatedLocation;
  bool _isLoading = false;
  var _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _userId = widget.userId;
    _notificationId = widget.notificationId;
    _crimeId = widget.crimeId;
    print("_crimeId $_crimeId");
    _crimeDescription = widget.crimedescription;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Material(
        child: CustomProgressBar(
          isLoading: _isLoading,
          widget: Form(
            key: _formKey,
            child: _body(),
          ),
        ),
      ),
    );
  }

  var timeFormat = new DateFormat("yyyy-MM-dd hh:mm a");
  Widget _timePicker() {
    return TimePickerSpinner(
      is24HourMode: false,
      normalTextStyle:
          TextStyle(fontSize: 20, color: Color.fromRGBO(27, 29, 77, 1)),
      highlightedTextStyle: TextStyle(fontSize: 30, color: Colors.orange),
      spacing: 40,
      itemHeight: 80,
      isForce2Digits: true,
      onTimeChange: (time) {
        setState(() {
          _timeOfDay = time;
        });
      },
    );
  }

  void _showPopPup(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 10,
          child: Container(
            //margin: EdgeInsets.only(left: 10, right: 10),
            height: 400.0,
            width: double.infinity,
            child: ListView(
              padding: EdgeInsets.all(0),
              children: <Widget>[
                SizedBox(height: 30),
                Center(
                  child: Text(
                    "Select Time",
                    style: GoogleFonts.poppins(
                        fontSize: 24,
                        color: Color.fromRGBO(27, 29, 77, 1),
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),
                _timePicker(),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                          padding: EdgeInsets.only(
                              top: 20.0, bottom: 15.0, left: 30.0, right: 5.0),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 40.0,
                            // height: double.infinity,
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              padding: const EdgeInsets.all(10.0),
                              color: Color.fromRGBO(24, 133, 239, 1),
                              textColor: Colors.white,
                              child: Text(
                                'Okay',
                                //textScaleFactor: 1.30,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500),
                              ),
                              onPressed: () {
                                setState(() async {
                                  Navigator.pop(context);
                                  _whenController.text =
                                      timeFormat.format(_timeOfDay).toString();
                                  ;
                                });
                              },
                            ),
                          )),
                    ),
                    Expanded(
                      child: Padding(
                          padding: EdgeInsets.only(
                              top: 20.0, bottom: 15.0, left: 5.0, right: 30.0),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 40.0,
                            // height: double.infinity,
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              padding: const EdgeInsets.all(10.0),
                              color: Color.fromRGBO(27, 29, 77, 1),
                              textColor: Colors.white,
                              child: Text(
                                'Cancel',
                                //textScaleFactor: 1.30,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500),
                              ),
                              onPressed: () {
                                setState(() async {
                                  _timeOfDay = null;
                                  Navigator.pop(context);
                                });
                              },
                            ),
                          )),
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _body() {
    return Container(
      child: ListView(
        children: <Widget>[
          SizedBox(height: 30),
          Center(
            child: Text(
              Tag_a_Crime_Text,
              style: titleTextStyleBlack,
            ),
          ),
          SizedBox(height: 15),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 10, bottom: 15),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "      please provider the below information to tag a crime.",
                style: GoogleFonts.sourceSansPro(
                  fontSize: 14,
                  color: MediumGreyColor,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                Where_Text,
                style: menuTextStyle,
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Card(
                  margin: EdgeInsets.only(
                      left: 20.0, right: 10.0, top: 10.0, bottom: 5.0),
                  elevation: 5,
                  child: TypeAheadFormField(
                    validator: (String value) {
                      if (value.isEmpty) {
                        return "please enter or select the location";
                      } else {
                        return null;
                      }
                    },
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: _whereController,
                      maxLines: null,
                      autofocus: false,
                      style: textBoxTextStyleBlack,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AshColor,
                        errorStyle: textBoxErrorTextStyle,
                        enabledBorder: textBoxEnabledUnderlineDecoration,
                        focusedBorder: textBoxFocusedUnderlineDecoration,
                        border: InputBorder.none,
                      ),
                    ),
                    suggestionsCallback: (pattern) async {
                      return await BackendService.getSuggestions(pattern);
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        leading: Icon(Icons.location_on),
                        title: Text(suggestion["description"]),
                      );
                    },
                    onSuggestionSelected: (suggestion) {
                      _searchAddress = suggestion['description'];
                      setState(() {
                        _whereController.text = _searchAddress;
                        if (_searchAddress != null) {
                          _whereController.text = _currentAddress;
                          _searchAndNavigateSource();
                        } else {}
                      });
                    },
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    color: BlueColor,
                    borderRadius: BorderRadius.all(Radius.circular(6))),
                margin: EdgeInsets.only(right: 10),
                child: IconButton(
                  icon: Icon(
                    Icons.my_location,
                    color: Colors.white,
                  ),
                  onPressed: () => _getCurrentLocation(),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                When_Text,
                style: menuTextStyle,
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Card(
                  margin: EdgeInsets.only(
                      left: 20.0, right: 10.0, top: 10.0, bottom: 5.0),
                  elevation: 5,
                  child: TextFormField(
                    enabled: false,
                    style: textBoxTextStyleBlack,
                    controller: _whenController,
                    validator: (String value) {
                      if (value.isEmpty) {
                        return "please select the time";
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AshColor,
                      errorStyle: textBoxErrorTextStyle,
                      enabledBorder: textBoxEnabledUnderlineDecoration,
                      focusedBorder: textBoxFocusedUnderlineDecoration,
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    color: BlueColor,
                    borderRadius: BorderRadius.all(Radius.circular(6))),
                margin: EdgeInsets.only(right: 10),
                child: IconButton(
                  icon: Icon(
                    FontAwesomeIcons.calendarTimes,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _whenController.clear();
                    });
                    _showPopPup(context);
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                Comments_Text,
                style: menuTextStyle,
              ),
            ),
          ),
          Card(
            elevation: 5,
            margin: EdgeInsets.only(
                left: 20.0, right: 20.0, top: 10.0, bottom: 5.0),
            child: TextFormField(
              autofocus: false,
              style: textBoxTextStyleBlack,
              controller: _commentsController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AshColor,
                errorStyle: textBoxErrorTextStyle,
                enabledBorder: textBoxEnabledUnderlineDecoration,
                focusedBorder: textBoxFocusedUnderlineDecoration,
              ),
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _completeButton(),
                ),
                Expanded(
                  child: _cancelTimeButton(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _completeButton() {
    var startBtn = Padding(
      padding: EdgeInsets.only(top: 10.0, bottom: 15.0, left: 20.0, right: 5.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 45.0,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          padding: const EdgeInsets.all(10.0),
          color: BlueColor,
          child: Text(
            Complete_Text,
            textScaleFactor: 1.15,
            style: btnTextStyleWhite,
          ),
          onPressed: () {
            setState(() async {
              if (_formKey.currentState.validate()) {
                bool connectionResult = await Utility.checkConnection();
                if (connectionResult) {
                  setState(() {
                    _isLoading = true;
                  });

                  CreateMarkerDetails newPost = new CreateMarkerDetails(
                    userId: int.parse(_userId),
                    latitude: _updatedLocation.latitude.toString(),
                    comments: _commentsController.text,
                    lastSeenAddress: _currentAddress,
                    longitude: _updatedLocation.longitude.toString(),
                    notificationId: int.parse(_notificationId),
                    timeOfSeeing: _whenController.text,
                    crimeId: int.parse(_crimeId),
                    notificationContent: _crimeDescription,
                  );
                  await createNewCrimePost(CreateMarkerDetails_Url,
                      body: newPost.toMap());
                } else {
                  Utility.showToast(context, Error_No_Internet_Text);
                }
              }
            });
          },
        ),
      ),
    );
    return startBtn;
  }

  Widget _cancelTimeButton() {
    var startBtn = Padding(
      padding:
          EdgeInsets.only(top: 10.0, bottom: 15.0, left: 10.0, right: 20.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 45.0,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          padding: EdgeInsets.all(10.0),
          color: DarkBlueColor,
          child: Text(
            Cancel_Text,
            textScaleFactor: 1.15,
            style: btnTextStyleWhite,
          ),
          onPressed: () {
            setState(() async {
              _commentsController.text = '';
              _whenController.text = '';
              _whereController.text = '';
              _timeOfDay = null;
              Navigator.pop(context);
            });
          },
        ),
      ),
    );
    return startBtn;
  }

  Future createNewCrimePost(String url, {Map body}) async {
    try {
      setState(() {
        _isLoading = true;
      });
      API.putAPI(CreateMarkerDetails_Url, "", body).then((response) {
        final int statusCode = response.statusCode;
        if (statusCode == 200) {
          setState(() {
            _isLoading = false;
          });
          Utility.showToast(context, "Crime tagged Successfully");
          Navigator.pop(context);
        } else {
          setState(() {
            _isLoading = false;
          });
          _errorAlert(context, Error_Something_WentWrong_Text);
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print(e);
    }
  }

  Future<bool> _errorAlert(BuildContext context, String error) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.only(left: 25, top: 10),
          title: Text('Error'),
          content: Text(error),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _getCurrentLocation() {
    _geoLocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        _updatedLocation =
            LatLng(_currentPosition.latitude, _currentPosition.longitude);
      });

      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await _geoLocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];
      setState(() {
        _currentAddress =
            "${place.name},${place.thoroughfare},${place.subLocality},${place.locality},${place.administrativeArea},${place.country},${place.postalCode}";
        // _currentTime = "${place.administrativeArea}";
        setState(() {
          _whereController.text = _currentAddress;
        });
      });
    } catch (e) {
      print('_getAddressFromLatLng $e');
    }
  }

  void _searchAndNavigateSource() async {
    Geolocator().placemarkFromAddress(_searchAddress).then((value) {
      setState(() {
        _updatedLocation =
            LatLng(value[0].position.latitude, value[0].position.longitude);
      });
    });
  }
}
