import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dragnet/models/requests/sendcrimenotification_request.dart';
import 'package:dragnet/models/responses/active_crime_response.dart';
import 'package:dragnet/models/responses/crime_details.dart';
import 'package:dragnet/models/responses/error_response.dart';
import 'package:dragnet/models/responses/gerAgents_Request.dart';
import 'package:dragnet/screens/common/google_signin.dart';
import 'package:dragnet/screens/common/profile_screen.dart';
import 'package:dragnet/screens/user/chats/agent_chat_ui.dart';
import 'package:dragnet/screens/user/chats/crime_chat_ui.dart';
import 'package:dragnet/screens/user/crime_tag_screen.dart';
import 'package:dragnet/screens/user/navigation_maps.dart';
import 'package:dragnet/screens/user/notification_screen.dart';
import 'package:dragnet/services/api_services.dart';
import 'package:dragnet/services/backen_service.dart';
import 'package:dragnet/services/place_detail.dart';
import 'package:dragnet/utils/Utility.dart';
import 'package:dragnet/utils/colors.dart';
import 'package:dragnet/utils/constants.dart';
import 'package:dragnet/utils/custom_textstyles.dart';
import 'package:dragnet/utils/service_urls.dart';
import 'package:dragnet/widgets/custom_profile_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as loc;
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final bool isMissing;
  CrimeDetails crimeDetails;
  HomePage({Key key, this.isMissing, this.crimeDetails}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  bool _isMissingAlertTriggered;
  CrimeDetails _crimeDetailsData;
  var _formKey = GlobalKey<FormState>();
  TextEditingController searchResultsController = TextEditingController();
  GoogleMap maps;
  CameraPosition _initialCamera;
  GoogleMapController mapController;
  LatLng _missingLocationLatLng;
  LatLng _updateMissingLocationLatLng;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _controller = Completer();
  double zoomVal = 5.0;
  Set<Marker> _markers = {};
  Position currentLocation;
  Position destinationLocation;
  String _userName;
  String _email;
  String ProfileImage;
  Set<Polyline> _polyLines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints;
  String googleAPIKey = 'AIzaSyBZU7X97LNq3k6cjg_AmYRofm8-wj8n5_k';
  // for my custom icons
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
  Set<Circle> circles;
  Image _profileImage;
  bool _isDirectionEnabled = false;
  String _crimeId = '';
  String _crimeName = '';
  String _crimeDescription = '';
  String _occurrenceAddress = '';
  String _dateOfOccurrence = '';
  String _timeOfOccurrence = '';
  double _latitude;
  double _longitude;
  Timer timer;
  Geolocator geoLocator = Geolocator()..forceAndroidLocationManager = true;
  Position _currentPosition;
  String _currentAddress;
  String severity;
  int _userId;
  bool _isGoogleLogged = false;
  ActiveCrimes activeCrimeList;
  BitmapDescriptor _missingIcon;
  var _placeholderImage = AssetImage('images/profile.png');
  int notificationId;
  bool _isBikeSelected = false;
  bool _isCarSelected = false;
  bool _isTaxiSelected = false;
  bool _isExpanded = false;
  final loc.Location location = loc.Location();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    polylinePoints = PolylinePoints();
    _loadGlobalValues();
    setSourceAndDestinationIcons();
//    timer = Timer.periodic(
//        Duration(seconds: 30), (Timer t) => _getCurrentLocation());
    var locationOptions =
        LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
    StreamSubscription<Position> positionStream = geoLocator
        .getPositionStream(locationOptions)
        .listen((Position position) {
      currentLocation = position;
    });
    _getCurrentLocation();
    _getCrimeRequest();
    _getNearByAgents();
  }

  void _loadGlobalValues() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('UserName') ?? '';
      _email = prefs.getString('Email') ?? '';
      _userId = prefs.getInt('UserId') ?? '';
      ProfileImage = prefs.getString('ProfileImage') ?? "";
      _isGoogleLogged = prefs.getBool('IsGoogleLoggedIn') ?? '';
    });
  }

  void setSourceAndDestinationIcons() async {
    _missingIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'location_alert.png');
  }

  void _getCrimeRequest() async {
    http.Response response = await http.get(
      Active_Crime_Url,
      headers: {
        "content-type": "application/json",
        "accept": "application/json",
      },
    );
    int statusCode = response.statusCode;
    if (statusCode == 200) {
      var result = json.decode(response.body);
      var items = ActiveCrimes.fromJson(result);
      for (var item in items.data) {
        if (item != null) {
          var icon;
          if (item.severity == 'high') {
            icon = BitmapDescriptor.hueRed;
          } else if (item.severity == 'low') {
            icon = BitmapDescriptor.hueYellow;
          } else {
            icon = BitmapDescriptor.hueOrange;
          }
          Marker resultMarker = Marker(
            markerId: MarkerId(item.crimeId.toString()),
            infoWindow: InfoWindow(
                title: "${item.crimeName}",
                snippet: "${item.crimeDescription}"),
            position: LatLng(double.parse(item.occurrencelatitude),
                double.parse(item.occurrencelongitude)),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              icon,
            ),
            onTap: () {
              _crimeId = item.crimeId.toString();
              _crimeName = item.crimeName;
              _crimeDescription = item.crimeDescription;
              _occurrenceAddress = item.occurrenceAddress;
              _dateOfOccurrence = item.createdDateTime;
              _timeOfOccurrence = item.timeOfOccurrence;
              _latitude = double.parse(item.occurrencelatitude);
              _longitude = double.parse(item.occurrencelongitude);
              _missingLocationLatLng = LatLng(_latitude, _longitude);
              _showActiveModalSheetMissingAlert();
            },
          );
          // Add it to Set
          _markers.add(resultMarker);
        }
      }
    } else {}
  }

  BitmapDescriptor pinLocationIcon;
  void _getNearByAgents() async {
    http.Response response = await http.get(
      Get_NearestPerson_Url,
      headers: {
        "content-type": "application/json",
        "accept": "application/json",
      },
    );
    int statusCode = response.statusCode;
    if (statusCode == 200) {
      Iterable result = json.decode(response.body);
      List<GetAgentsResponse> agentsList =
          result.map((model) => GetAgentsResponse.fromJson(model)).toList();
      pinLocationIcon = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(devicePixelRatio: 3), 'images/agent_icon.png');
      for (var item in agentsList) {
        if (item != null) {
          Marker resultMarker = Marker(
            markerId: MarkerId(item.userId.toString()),
            infoWindow: InfoWindow(title: "${item.name}"),
            position: LatLng(
                double.parse(item.latitude), double.parse(item.longitude)),
            icon: pinLocationIcon,
            onTap: () {
              _showAgent(item);
            },
          );
          // Add it to Set
          _markers.add(resultMarker);
        }
      }
    } else {}
  }

  String _agentAddress;
  _getAgentAddress(double latitude, double longitude) async {
    try {
      List<Placemark> p =
          await geoLocator.placemarkFromCoordinates(latitude, longitude);
      Placemark place = p[0];
      setState(() {
        _agentAddress =
            "${place.name},${place.thoroughfare},${place.subLocality},${place.locality},${place.administrativeArea},${place.country},${place.postalCode}";
        _updateLocationToCloud();
      });
    } catch (e) {
      print('_getAddressFromLatLng $e');
    }
  }

  void _showAgent(GetAgentsResponse _item) {
    _getAgentAddress(
        double.parse(_item.latitude), double.parse(_item.longitude));
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (builder) {
          return Container(
            margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(6.0),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 10.0, top: 10),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Material(
                      elevation: 6.0,
                      color: DarkBlueColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: GestureDetector(
                          child: Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Icon(
                              Icons.clear,
                              size: 20.0,
                              color: Colors.white,
                            ),
                          ),
                          onTap: () => Navigator.pop(context)),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20.0, top: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Image.asset(
                        "images/agent_icon.png",
                        height: 90,
                        width: 90,
                        fit: BoxFit.fill,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              _item.name,
                              style: GoogleFonts.poppins(
                                  fontSize: 25,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500
                                  //decoration: TextDecoration.underline,
                                  ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Material(
                              elevation: 6.0,
                              color: Color.fromRGBO(225, 130, 4, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: 15,
                                  right: 15,
                                  top: 5,
                                  bottom: 5,
                                ),
                                child: Text(
                                  "Agent",
                                  style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500
                                      //decoration: TextDecoration.underline,
                                      ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: 30.0, top: 25, bottom: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Material(
                        elevation: 6.0,
                        color: BlueColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Icon(
                            Icons.my_location,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Flexible(
                        child: Text(
                          _agentAddress,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Colors.grey,
                            //fontWeight: FontWeight.w500
                            //decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // _buildContainer(),
                Padding(
                  padding: EdgeInsets.only(left: 5.0, top: 5, bottom: 10),
                  child: _chatButton(_item.userId),
                )
              ],
            ),
          );
        });
  }

  Widget _chatButton(int agentId) {
    var chat = Container(
      margin: EdgeInsets.only(bottom: 10.0),
      width: 110,
      height: 37.0,
      child: new RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        color: Color.fromRGBO(225, 130, 4, 1),
        child: Text(
          "Chat",
          style: btnTextStyleWhiteBold,
        ),
        onPressed: () {
          Navigator.pop(context);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => AgentChatPage(
                agentId: agentId,
              ),
            ),
          );
        },
      ),
    );
    return Center(
      child: chat,
    );
  }

  void _showActiveModalSheetMissingAlert() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (builder) {
          return Container(
            margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(6.0),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 10,
                  child: Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.maximize,
                      size: 40.0,
                      color: SilverColor,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          _crimeName,
                          style: GoogleFonts.poppins(
                              fontSize: 25,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500
                              //decoration: TextDecoration.underline,
                              ),
                        ),
                      ),
                      IconButton(
                          icon: Image.asset(
                            "images/information.png",
                            height: 30,
                            width: 30,
                          ),
                          onPressed: null),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20.0, top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Image.asset("images/miss_info.png"),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          _crimeDescription,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Colors.grey,
                            //fontWeight: FontWeight.w500
                            //decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20.0, top: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Image.asset("images/miss_location_icon.png"),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: Text(
                        _occurrenceAddress,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.grey,
                          //fontWeight: FontWeight.w500
                          //decoration: TextDecoration.underline,
                        ),
                      )),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20.0, top: 5, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Image.asset("images/miss_time_icon.png"),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        _dateOfOccurrence,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.grey,
                          //fontWeight: FontWeight.w500
                          //decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
                // _buildContainer(),
                Padding(
                  padding: EdgeInsets.only(left: 5.0, top: 5, bottom: 10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: <Widget>[
                        _seeButton(),
                        _startActiveButton(),
                        _commentsButton(),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }

  void _navigationModalSheet1() {
    Navigator.pop(context);
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (builder) {
          return Container(
            margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(6.0),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: 15,
                ),
                SizedBox(
                  height: 10,
                  child: Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.maximize,
                      size: 40.0,
                      color: SilverColor,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20.0, top: 20),
                  child: Text(
                    _occurrenceAddress,
                    style: menuTextStyle,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20.0, top: 10),
                  child: Text(
                    "12.5 kms away",
                    style: textStyleBlue,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20.0, top: 10, right: 20),
                  child: Divider(
                    thickness: 1,
                    color: Colors.black12,
                  ),
                ),
                _goNowButton(),
              ],
            ),
          );
        });
  }

  Widget _goNowButton() {
    var startBtn = Container(
      margin: EdgeInsets.only(top: 15.0, bottom: 20.0),
      width: 110,
      height: 37.0,
      child: new RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        color: BlueColor,
        child: Text(
          Go_Now_Text,
          style: btnTextStyleWhiteBold,
        ),
        onPressed: () {
          Navigator.pop(context);
          _navigationModalSheet2();
        },
      ),
    );
    return Center(
      child: startBtn,
    );
  }

  void _navigationModalSheet2() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (builder) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(6.0),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    height: 10,
                    child: Align(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.maximize,
                        size: 40.0,
                        color: SilverColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0, top: 10),
                    child: Text(
                      Change_Navigation_Icon_Text,
                      style: appBarTitleTextStyle,
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <Widget>[
                        Card(
                          margin: EdgeInsets.only(
                              left: 20.0, right: 15, top: 20, bottom: 5),
                          elevation: 5,
                          color: AshColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding:
                                EdgeInsets.only(left: 10, right: 20, top: 10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  "images/bike.png",
                                  height: 70,
                                  width: 70,
                                  fit: BoxFit.cover,
                                ),
                                Row(
                                  children: <Widget>[
                                    Checkbox(
                                        value: _isBikeSelected,
                                        onChanged: (bool newValue) {
                                          setState(() {
                                            _isBikeSelected = newValue;
                                            _isCarSelected = false;
                                            _isTaxiSelected = false;
                                          });
                                        }),
                                    Text(
                                      Motor_Cycle_Text,
                                      style: _isBikeSelected
                                          ? textStyleBlue
                                          : menuTextStyle,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        Card(
                          margin:
                              EdgeInsets.only(right: 15, top: 20, bottom: 5),
                          elevation: 5,
                          color: AshColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding:
                                EdgeInsets.only(left: 10, right: 20, top: 10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  "images/car.png",
                                  height: 70,
                                  width: 70,
                                  fit: BoxFit.cover,
                                ),
                                Row(
                                  children: <Widget>[
                                    Checkbox(
                                        value: _isCarSelected,
                                        onChanged: (bool newValue) {
                                          setState(() {
                                            _isCarSelected = newValue;
                                            _isBikeSelected = false;
                                            _isTaxiSelected = false;
                                          });
                                        }),
                                    Text(
                                      Private_Car_Text,
                                      style: _isCarSelected
                                          ? textStyleBlue
                                          : menuTextStyle,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        Card(
                          margin:
                              EdgeInsets.only(right: 15, top: 20, bottom: 5),
                          elevation: 5,
                          color: AshColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding:
                                EdgeInsets.only(left: 10, right: 20, top: 10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  "images/taxi.png",
                                  height: 70,
                                  width: 70,
                                  fit: BoxFit.cover,
                                ),
                                Row(
                                  children: <Widget>[
                                    Checkbox(
                                        value: _isTaxiSelected,
                                        onChanged: (bool newValue) {
                                          setState(() {
                                            _isTaxiSelected = newValue;
                                            _isCarSelected = false;
                                            _isBikeSelected = false;
                                          });
                                        }),
                                    Text(
                                      Taxi_Text,
                                      style: _isTaxiSelected
                                          ? textStyleBlue
                                          : menuTextStyle,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _saveButton()
                ],
              ),
            );
          });
        });
  }

  Widget _saveButton() {
    var startBtn = Container(
      margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
      width: 110,
      height: 37.0,
      child: new RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        color: BlueColor,
        child: Text(
          Save_Text,
          style: btnTextStyleWhiteBold,
        ),
        onPressed: () {
          Navigator.pop(context);
          circles = Set<Circle>();
          circles = Set.from([
            Circle(
              circleId: CircleId('1'),
              center: LatLng(_missingLocationLatLng.latitude,
                  _missingLocationLatLng.longitude),
              fillColor: Colors.black12,
              strokeColor: Colors.black,
              strokeWidth: 1,
              radius: 5000,
            )
          ]);
          _polyLines = Set<Polyline>();
          polylineCoordinates = [];
          polylinePoints = PolylinePoints();
          setPolyLines();
          _isExpanded = false;
          setState(() {
            _isStarted = true;
            _isFab = false;
          });
        },
      ),
    );
    return Center(
      child: startBtn,
    );
  }

  Widget _routeNavigationModalSheet() {
    return Container(
      margin: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(blurRadius: 0.6, color: Colors.black26)],
        borderRadius: BorderRadius.all(
          Radius.circular(6.0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: 25,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: 20,
              ),
              CircleAvatar(
                backgroundColor: BlueColor,
                radius: 19,
                child: IconButton(
                    iconSize: 20,
                    icon: Icon(
                      _isExpanded
                          ? FontAwesomeIcons.angleUp
                          : FontAwesomeIcons.angleDown,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      print("isExpanded");
                      if (_isExpanded) {
                        setState(() {
                          _isExpanded = false;
                        });
                      } else {
                        setState(() {
                          _isExpanded = true;
                        });
                      }
                    }),
              ),
              SizedBox(
                width: 15,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "You will arrive at 10:00 pm",
                      style: menuTextStyle,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "20 min - 10 miles",
                      style: textStyleBlue,
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                backgroundColor: BlueColor,
                radius: 20,
                child: Icon(
                  FontAwesomeIcons.route,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                width: 20,
              ),
            ],
          ),
          _isExpanded
              ? Padding(
                  padding: EdgeInsets.only(left: 10.0, top: 20, bottom: 5),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: <Widget>[
                        _seeButton(),
                        _gotButton(),
                        _cancelButton(),
                        _commentsButton(),
                      ],
                    ),
                  ),
                )
              : SizedBox(
                  height: 25,
                ),
        ],
      ),
    );
  }

  Widget _gotButton() {
    var startBtn = Container(
      margin: EdgeInsets.only(top: 15.0, bottom: 20.0, left: 5),
      width: 70,
      height: 37.0,
      child: new RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        color: DarkBlueColor,
        child: Text(
          Got_Text,
          style: btnTextStyleWhiteBold,
        ),
        onPressed: () {
          Navigator.pop(context);
          _isExpanded = false;
          _routeNavigationModalSheet();
        },
      ),
    );
    return Center(
      child: startBtn,
    );
  }

  Widget _cancelButton() {
    var startBtn = Container(
      margin: EdgeInsets.only(top: 15.0, bottom: 20.0, left: 10),
      width: 80,
      height: 37.0,
      child: new RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        color: DarkBlueColor,
        child: Text(
          Cancel_Text,
          style: btnTextStyleWhiteBold,
        ),
        onPressed: () {
          circles = Set<Circle>();
          _markers = Set<Marker>();
          _polyLines = Set<Polyline>();
          polylineCoordinates = [];
          polylinePoints = PolylinePoints();
          _currentLocation();
          _getCrimeRequest();
          _getNearByAgents();
          _isExpanded = false;
          setState(() {
            _isStarted = false;
            _isFab = true;
          });
        },
      ),
    );
    return Center(
      child: startBtn,
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _updateLocationToCloud() async {
    SendCrimeNotificationModel newPost = new SendCrimeNotificationModel(
        userId: _userId,
        latitude: _currentPosition.latitude.toString(),
        longitude: _currentPosition.longitude.toString());
    await sendCrimeNotificationPost(Send_Location_Url, body: newPost.toMap());
  }

  Future sendCrimeNotificationPost(String url, {Map body}) async {
    try {
      API.postAPI(url, "", body).then((response) {
        final int statusCode = response.statusCode;
        if (statusCode == 200) {
        } else {}
      });
    } catch (e) {
      print(e);
    }
  }

  void _showMissingAlert() async {
    var icon;
    if (severity == 'high') {
      icon = BitmapDescriptor.hueRed;
    } else if (severity == 'low') {
      icon = BitmapDescriptor.hueYellow;
    } else {
      icon = BitmapDescriptor.hueOrange;
    }
    final GoogleMapController controller = await _controller.future;
    setState(() {
      if (_isMissingAlertTriggered) {
        setSourceAndDestinationIcons();
        _markers.removeWhere((m) => m.markerId.value == 'miss_alert');
        Marker kidMiss = Marker(
          markerId: MarkerId('miss_alert'),
          position: LatLng(_missingLocationLatLng.latitude,
              _missingLocationLatLng.longitude),
          infoWindow: InfoWindow(title: _crimeDetailsData.crimeName),
          onTap: () {
            _showModalSheetMissingAlert();
          },
          icon: BitmapDescriptor.defaultMarkerWithHue(
            icon,
          ),
        );
        circles = Set.from([
          Circle(
            circleId: CircleId('1'),
            center: LatLng(_missingLocationLatLng.latitude,
                _missingLocationLatLng.longitude),
            fillColor: Color.fromRGBO(27, 29, 77, 0.3),
            strokeColor: Colors.black,
            strokeWidth: 1,
            radius: 3000,
          )
        ]);
        _markers.add(kidMiss);
        _controller.complete(mapController);
        controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            bearing: 13,
            tilt: 0,
            target: LatLng(_missingLocationLatLng.latitude,
                _missingLocationLatLng.longitude),
            zoom: 15.0,
          ),
        ));
        _initialCamera = CameraPosition(
          target: LatLng(_missingLocationLatLng.latitude,
              _missingLocationLatLng.longitude),
          zoom: 13.0000,
        );
        setMapPins();
      }
    });
  }

  void setMapPins() {
    setState(() {
      _markers.removeWhere((m) => m.markerId.value == 'miss_alert');
      _markers.add(
        Marker(
          markerId: MarkerId('miss_alert'),
          position: _missingLocationLatLng,
          icon: _missingIcon,
        ),
      );
    });
  }

  _getCurrentLocation() async {
    print("_getCurrentLocation entered");
    final Geolocator geolocator = Geolocator()
      ..forceAndroidLocationManager = true;
    bool isLocationEnabled = await geolocator.isLocationServiceEnabled();
    print("_getCurrentLocation isLocationEnabled $isLocationEnabled");
    Position position = await geolocator.getCurrentPosition();
    print("_getCurrentLocation position $position");
    _currentPosition = position;
    print("_getCurrentLocation ${position.latitude}");
    print("_getCurrentLocation ${position.longitude}");
    // print("_getCurrentLocation $e");
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geoLocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);
      Placemark place = p[0];
      setState(() {
        _currentAddress =
            "${place.name},${place.thoroughfare},${place.subLocality},${place.locality},${place.administrativeArea},${place.country},${place.postalCode}";
        _updateLocationToCloud();
      });
    } catch (e) {
      print('_getAddressFromLatLng $e');
    }
  }

  void setActivePolyLines(double latitude, double longitude) async {
    try {
      PolylineResult result = await polylinePoints?.getRouteBetweenCoordinates(
        googleAPIKey,
        PointLatLng(currentLocation.latitude, currentLocation.longitude),
        PointLatLng(latitude, longitude),
        travelMode: TravelMode.driving,
      );
      if (result.points.isNotEmpty) {
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      } else {
        _errorAlert(context, "Failed");
      }
      setState(() {
        _polyLines.add(Polyline(
            width: 5, // set the width of the polyLines
            polylineId: PolylineId("poly_routes"),
            color: Colors.red,
            points: polylineCoordinates));
      });
    } catch (e) {
      print('setActivePolyLines $e');
    }
  }

  void setPolyLines() async {
    try {
      PolylineResult result = await polylinePoints?.getRouteBetweenCoordinates(
        googleAPIKey,
        PointLatLng(currentLocation.latitude, currentLocation.longitude),
        PointLatLng(
            _missingLocationLatLng.latitude, _missingLocationLatLng.longitude),
        travelMode: TravelMode.driving,
      );
      if (result.points.isNotEmpty) {
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      } else {
        _errorAlert(context, "Failed");
      }
      setState(() {
        _polyLines.add(
          Polyline(
              width: 5,
              polylineId: PolylineId("poly_routes"),
              color: RouteLineColor,
              points: polylineCoordinates),
        );
      });
    } catch (e) {
      print('setPolyLines $e');
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

  void showPinsOnMap() async {
    try {
      final GoogleMapController controller = await _controller.future;
      print("showPinsOnMap entered");
      var pinPosition =
          LatLng(_currentPosition.latitude, _currentPosition.longitude);
      _markers.add(
        Marker(
          markerId: MarkerId('sourcePin'),
          position: pinPosition,
          icon: await BitmapDescriptor.fromAssetImage(
              ImageConfiguration(devicePixelRatio: 5), 'images/source.png'),
        ),
      );
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            bearing: 13,
            target:
                LatLng(_currentPosition.latitude, _currentPosition.longitude),
            zoom: 15.0,
          ),
        ),
      );
    } catch (e) {
      print("showPinsOnMap $e");
    }
  }

  void updatePinOnMap() async {
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
    );
  }

  Future createNewCrimePost(String url, {Map body}) async {
    try {
      API.putAPI(CreateMarkerDetails_Url, "", body).then((response) {
        final int statusCode = response.statusCode;
        if (statusCode == 200) {
          _updateMissingAlert();
          Utility.showToast(context, "Crime tagged Successfully");
        } else {
          final Map parsed = json.decode(response.body);
          final user = ErrorResponse.fromJson(parsed);
          var error = user.errorMessage;
          _errorAlert(context, error);
        }
      });
    } catch (e) {
      print(e);
    }
  }

  bool _isStarted = false;
  bool _isFab = true;
  @override
  Widget build(BuildContext context) {
    setState(() {
      _isMissingAlertTriggered = widget.isMissing;
      _crimeDetailsData = widget.crimeDetails;

      print(_isMissingAlertTriggered);
      if (_isMissingAlertTriggered == true) {
        try {
          _missingLocationLatLng = LatLng(
              double.parse(_crimeDetailsData.occurrenceLatitude),
              double.parse(_crimeDetailsData.occurrenceLongitude));
          notificationId = int.parse(_crimeDetailsData.notificationId);
          severity = _crimeDetailsData.severity;
          _showMissingAlert();
        } catch (e) {
          _errorAlert(context, _crimeDetailsData.occurrenceLatitude);
        }
      }
    });

    // TODO: implement build
    return WillPopScope(
      onWillPop: () => _onCloseApp(),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: _drawerMenu(),
        body: Stack(
          children: <Widget>[
            _buildGoogleMap(context),
            _autoSearch(),
            Visibility(
              visible: _isStarted,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: _routeNavigationModalSheet(),
              ),
            ),
          ],
        ),
        floatingActionButton: Visibility(
          visible: _isFab,
          child: _fab(),
        ),
      ),
    );
  }

  Future<bool> _onCloseApp() {
    return showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => new AlertDialog(
            contentPadding:
                EdgeInsets.only(top: 10, bottom: 10, left: 25, right: 20),
            title: new Text(Are_you_sure_Text),
            content: new Text(Do_you_want_to_close_the_app_Text),
            // actionsPadding: EdgeInsets.only(top: 5, bottom: 10, right: 10),
            actions: <Widget>[
              new GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: roundedButton(
                    No_Text, DarkBlueColor, const Color(0xFFFFFFFF)),
              ),
              new GestureDetector(
                onTap: () {
                  exit(0);
                },
                child: roundedButton(
                    Yes_Text, DarkBlueColor, const Color(0xFFFFFFFF)),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _onBackPressed() {
    return showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => new AlertDialog(
            contentPadding: EdgeInsets.only(top: 10, bottom: 5, left: 25),
            title: new Text('Are you sure?'),
            content: new Text('Do you want to logout.'),
            actions: <Widget>[
              new GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: roundedButton("No", Color.fromRGBO(27, 29, 77, 1),
                    const Color(0xFFFFFFFF)),
              ),
              new GestureDetector(
                onTap: () {
                  CrimeDetails('', '', '', '', '', '', '', '', '', '');
                  Navigator.pop(context);
                  if (_isGoogleLogged) {
                    signOutGoogle();
                  }
                  setState(() async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setBool("isLoggedIn", false);
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        '/login', (Route<dynamic> route) => false);
                  });
                },
                child: roundedButton(" Yes ", Color.fromRGBO(27, 29, 77, 1),
                    const Color(0xFFFFFFFF)),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget roundedButton(String buttonLabel, Color bgColor, Color textColor) {
    var loginBtn = new Container(
      margin: EdgeInsets.only(bottom: 5, right: 5),
      padding: EdgeInsets.only(left: 15, right: 15, top: 7, bottom: 7),
      alignment: FractionalOffset.center,
      decoration: new BoxDecoration(
        color: bgColor,
        borderRadius: new BorderRadius.all(const Radius.circular(6.0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF696969),
            offset: Offset(1.0, 6.0),
            blurRadius: 0.001,
          ),
        ],
      ),
      child: Text(
        buttonLabel,
        style: new TextStyle(
            color: textColor, fontSize: 16.0, fontWeight: FontWeight.w500),
      ),
    );
    return loginBtn;
  }

  void _showModalSheetMissingAlert() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (builder) {
          return Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(6.0),
                topRight: const Radius.circular(6.0),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.maximize,
                    size: 20.0,
                    color: Colors.grey,
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      _crimeDetailsData.crimeName,
                      style: GoogleFonts.poppins(
                          fontSize: 25,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(_crimeDetailsData.crimeDescription,
                        style: GoogleFonts.poppins(
                            fontSize: 18, color: Colors.grey)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20.0, top: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.location_on,
                        color: Colors.pink,
                        //size: 25,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          _crimeDetailsData.occurrenceAddress,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20.0, top: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.watch_later,
                        color: Colors.pink,
                        // size: 20,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        _crimeDetailsData.dateOfOccurence,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                // _buildContainer(),
                Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: <Widget>[
                      _seeNotificationButton(),
                      _startButton(),
                      _commentsButton(),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget _seeNotificationButton() {
    var startBtn = Padding(
      padding: EdgeInsets.only(top: 10.0, bottom: 15.0, left: 15.0, right: 5.0),
      child: SizedBox(
        width: 110,
        height: 35.0,
        child: new RaisedButton.icon(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          icon: Icon(
            FontAwesomeIcons.eye,
            color: Colors.white,
          ),
          color: Color.fromRGBO(24, 133, 239, 1),
          textColor: Colors.white,
          label: Text(
            'See',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          onPressed: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => CrimeTagPage(
                      notificationId: _crimeDetailsData.notificationId,
                      userId: _userId.toString(),
                      crimeId: _crimeDetailsData.crimeId,
                      crimedescription: _crimeDetailsData.crimeDescription,
                    )));
          },
        ),
      ),
    );
    return startBtn;
  }

  Widget _autoSearch() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(6)),
          boxShadow: [
            BoxShadow(
              blurRadius: 5,
              color: Colors.grey,
            )
          ]),
      height: 50.0,
      padding: EdgeInsets.only(top: 5.0, right: 5),
      margin: EdgeInsets.only(top: 45.0, left: 12.0, right: 12.0),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Image.asset("images/menu.png"),
            onPressed: () => onNavigateToMenu(),
          ),
          Expanded(
            child: TypeAheadFormField(
              textFieldConfiguration: TextFieldConfiguration(
                textAlign: TextAlign.center,
                controller: searchResultsController,
                maxLines: 1,
                //autofocus: false,
                style: TextStyle(color: TextColor),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(5),
                  border: InputBorder.none,
                  hintText: 'Where to ?',
                  hintStyle: TextStyle(
                    color: TextColor,
                    fontSize: 17.0,
                  ),
                  isDense: true,
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
                  searchResultsController.text = _searchAddress;
                  if (_searchAddress != null) {
                    _searchAndNavigate();
                  } else {}
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  void onNavigateToMenu() {
    //FocusScope.of(context).requestFocus(FocusNode());
    searchResultsController.clear();
    _scaffoldKey.currentState.openDrawer();
  }

  Widget row(predictions user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          user.description,
          style: TextStyle(fontSize: 16.0),
        ),
        SizedBox(
          width: 10.0,
        ),
      ],
    );
  }

  String _searchAddress;
  void _searchAndNavigate() async {
    final GoogleMapController controller = await _controller.future;
    Geolocator().placemarkFromAddress(_searchAddress).then((value) {
      _markers.removeWhere((m) => m.markerId.value == 'sear_loca');

      Marker Serach_location = Marker(
        markerId: MarkerId('sear_loca'),
        position:
            LatLng(value[0].position.latitude, value[0].position.longitude),
        onTap: () {
          setState(() {
            _isDirectionEnabled = true;
          });
        },
        infoWindow: InfoWindow(title: _searchAddress),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen,
        ),
      );
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            bearing: 13,
            target:
                LatLng(value[0].position.latitude, value[0].position.longitude),
            zoom: 15.0,
          ),
        ),
      );
      setState(() {
        _markers.add(Serach_location);
        _initialCamera = CameraPosition(
          target:
              LatLng(value[0].position.latitude, value[0].position.longitude),
          zoom: 14.0000,
        );
      });
    });
  }

  Widget _seeButton() {
    var startBtn = Container(
      margin: EdgeInsets.only(top: 10.0, bottom: 15.0, left: 15.0, right: 5.0),
      width: 110,
      height: 37.0,
      child: new RaisedButton.icon(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        icon: Icon(
          Icons.remove_red_eye,
          color: Colors.white,
        ),
        color: BlueColor,
        label: Text(
          Seen_Text,
          style: btnTextStyleWhiteBold,
        ),
        onPressed: () {
          Navigator.pop(context);
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => CrimeTagPage(
                    notificationId: "0",
                    userId: _userId.toString(),
                    crimeId: _crimeId,
                    crimedescription: _crimeDescription,
                  )));
        },
      ),
    );
    return startBtn;
  }

  Widget _startButton() {
    var startBtn = Container(
      margin: EdgeInsets.only(top: 10.0, bottom: 15.0, left: 10.0, right: 5.0),
      width: 110,
      height: 35.0,
      child: new RaisedButton.icon(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        icon: Icon(
          FontAwesomeIcons.directions,
          color: Colors.white,
          size: 15,
        ),
        color: Color.fromRGBO(27, 29, 77, 1),
        textColor: Colors.white,
        label: Text(
          'Start',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        onPressed: () {
          setState(() async {
            _polyLines = Set<Polyline>();
            polylineCoordinates = [];
            polylinePoints = PolylinePoints();
            setPolyLines();
            Navigator.pop(context);
          });
        },
      ),
    );
    return startBtn;
  }

  Widget _startActiveButton() {
    var startBtn = Container(
      margin: EdgeInsets.only(top: 10.0, bottom: 15.0, left: 10.0, right: 5.0),
      width: 140,
      height: 37.0,
      child: new RaisedButton.icon(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        icon: Icon(
          Icons.directions,
          color: Colors.white,
        ),
        color: DarkBlueColor,
        textColor: Colors.white,
        label: Text(
          Navigation_Text,
          style: btnTextStyleWhiteBold,
        ),
        onPressed: () {
          _polyLines = Set<Polyline>();
          polylineCoordinates = [];
          polylinePoints = PolylinePoints();
          setPolyLines();
          _navigationModalSheet1();
        },
      ),
    );
    return startBtn;
  }

  Widget _commentsButton() {
    var commentsBtn = Container(
      width: 40,
      height: 37.0,
      margin: EdgeInsets.only(left: 10, bottom: 5),
      decoration: BoxDecoration(
          boxShadow: [BoxShadow(blurRadius: 0.5, color: TangoColor)],
          color: TangoColor,
          borderRadius: BorderRadius.all(Radius.circular(6))),
      child: IconButton(
        //padding: const EdgeInsets.all(10.0),
        color: TangoColorDark,
        icon: Icon(Icons.chat),
        onPressed: () {
          setState(() async {
            //Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) => CrimeChatPage(
                  crimeId: _crimeId,
                ),
              ),
            );
          });
        },
      ),
    );
    return commentsBtn;
  }

  void _updateMissingAlert() async {
    var icon;
    if (severity == 'high') {
      icon = BitmapDescriptor.hueRed;
    } else if (severity == 'low') {
      icon = BitmapDescriptor.hueYellow;
    } else {
      icon = BitmapDescriptor.hueOrange;
    }

    _missingLocationLatLng = LatLng(_updateMissingLocationLatLng.latitude,
        _updateMissingLocationLatLng.longitude);
    print(
        'MissingLocationLatLng ${_updateMissingLocationLatLng.latitude + _updateMissingLocationLatLng.longitude}');
    final GoogleMapController controller = await _controller.future;

    setState(() {
      _markers.removeWhere((m) => m.markerId.value == 'curr_loca');
      _markers.removeWhere((m) => m.markerId.value == 'kid_miss');
      Marker updateKidMiss = Marker(
        markerId: MarkerId('update_kid_miss'),
        position: LatLng(_updateMissingLocationLatLng.latitude,
            _updateMissingLocationLatLng.longitude),
        infoWindow: InfoWindow(title: _crimeDetailsData.crimeName),
        onTap: () {
          _showModalSheetMissingAlert();
        },
        icon: BitmapDescriptor.defaultMarkerWithHue(
          icon,
        ),
      );
      circles = Set<Circle>();
      circles = Set.from([
        Circle(
          circleId: CircleId('1'),
          center: LatLng(_updateMissingLocationLatLng.latitude,
              _updateMissingLocationLatLng.longitude),
          fillColor: Colors.black12,
          strokeColor: Colors.black,
          strokeWidth: 1,
          radius: 5000,
        )
      ]);
      _markers.add(updateKidMiss);
      _controller.complete(mapController);
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 13,
          //tilt: 0,
          target: LatLng(_updateMissingLocationLatLng.latitude,
              _updateMissingLocationLatLng.longitude),
          zoom: 13.0,
        ),
        //_markers.add(current_location),
      ));
      _initialCamera = CameraPosition(
        target: LatLng(_updateMissingLocationLatLng.latitude,
            _updateMissingLocationLatLng.longitude),
        zoom: 13.0000,
      );
    });
  }

  Widget _drawerMenu() {
    _loadGlobalValues();
    var drawer = Drawer(
      child: SafeArea(
        right: false,
        child: Center(
          child: Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                UserAccountsDrawerHeader(
                  accountName: Text(
                    _userName,
                    style: GoogleFonts.sourceSansPro(
                      fontSize: 20.0,
                      color: DarkTextColor,
                      fontWeight: FontSemiBold,
                    ),
                  ),
                  accountEmail: Text(
                    _email,
                    style: GoogleFonts.sourceSansPro(
                      fontSize: 15.0,
                      color: MediumGreyColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  decoration: new BoxDecoration(
                    color: Colors.white,
                  ),
                  currentAccountPicture:
                      CustomProfileImage(url: ProfileImage, radius: 26),
                ),
                SizedBox(
                  height: 15,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: 25,
                      ),
                      Icon(
                        FontAwesomeIcons.home, size: 18,
                        color: MenuIconColor,
                        //color: Colors.blue,
                      ),
                      SizedBox(
                        width: 25,
                      ),
                      Text(
                        Home_Text,
                        style: menuTextStyle,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => ProfilePage()));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: 25,
                      ),
                      Icon(
                        FontAwesomeIcons.userAlt,
                        size: 18,
                        color: MenuIconColor,
                      ),
                      SizedBox(
                        width: 25,
                      ),
                      Text(
                        Profile_Text,
                        style: menuTextStyle,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) =>
                            NotificationsPage()));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: 25,
                      ),
                      Icon(
                        FontAwesomeIcons.solidBell,
                        size: 18,
                        color: MenuIconColor,
                      ),
                      SizedBox(
                        width: 25,
                      ),
                      Text(
                        Notification_Text,
                        style: menuTextStyle,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Expanded(
                  flex: 5,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: SizedBox(),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              _onBackPressed();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Icon(
                                  FontAwesomeIcons.powerOff,
                                  size: 18,
                                  color: MenuIconColor,
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  SignOut_Text,
                                  style: menuTextStyle,
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ),
      ),
    );
    return drawer;
  }

  Widget _fab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Material(
          elevation: 4.0,
          shape: CircleBorder(),
          clipBehavior: Clip.hardEdge,
          color: Colors.blue,
          child: IconButton(
            icon: Icon(
              Icons.my_location,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _currentLocation();
              });
            },
          ),
        ),
        SizedBox(
          height: 15.0,
        ),
        Material(
          elevation: 4.0,
          shape: CircleBorder(),
          clipBehavior: Clip.hardEdge,
          color: Colors.blue,
          child: IconButton(
            color: Colors.blue,
            icon: Icon(
              Icons.directions,
              color: Colors.white,
            ),
            onPressed: () {
              searchResultsController.clear();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NavigationHomePage()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleMap(BuildContext context) {
    CameraPosition initialLocation = CameraPosition(
      zoom: CAMERA_ZOOM,
      bearing: CAMERA_BEARING,
      tilt: CAMERA_TILT,
      target: LatLng(0.0, 0.0),
    );
    maps = GoogleMap(
      indoorViewEnabled: true,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomGesturesEnabled: true,
      compassEnabled: false,
      scrollGesturesEnabled: true,
      rotateGesturesEnabled: true,
      circles: circles,
      tiltGesturesEnabled: true,
      mapToolbarEnabled: false,
      markers: _markers.toSet(),
      polylines: _polyLines,
      mapType: MapType.normal,
      initialCameraPosition: initialLocation,
      onMapCreated: onMapCreated,
    );

    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: maps,
    );
  }

  void onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    showPinsOnMap();
  }

  void _currentLocation() async {
    try {
      final GoogleMapController controller = await _controller.future;
      print("_currentLocation Func - Start");
      loc.LocationData currentLocation;
      try {
        currentLocation = await location.getLocation();
        print("_currentLocation ${currentLocation.latitude}");
        print("_currentLocation ${currentLocation.longitude}");
      } catch (e) {
        print("_currentLocation Func - $e");
        currentLocation = null;
      }

      Marker curr_loca = Marker(
        markerId: MarkerId('curr_loca'),
        position: LatLng(currentLocation.latitude, currentLocation.longitude),
        infoWindow: InfoWindow(title: 'My Current Location'),
        onTap: () {
          controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                bearing: 13,
                target:
                    LatLng(currentLocation.latitude, currentLocation.longitude),
                zoom: 15.0,
              ),
            ),
          );
        },
        icon: await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 5), 'images/source.png'),
      );
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            bearing: 13,
            target: LatLng(currentLocation.latitude, currentLocation.longitude),
            zoom: 15.0,
          ),
        ),
      );
      setState(() {
        _markers.add(curr_loca);
        _initialCamera = CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: 14.0000,
        );
      });
      showPinsOnMap();
    } catch (e) {
      print("_currentLocation Func - $e");
    }
  }
}
