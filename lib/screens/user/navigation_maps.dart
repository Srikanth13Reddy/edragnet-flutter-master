import 'dart:async';
import 'dart:convert';

import 'package:dragnet/models/requests/sendcrimenotification_request.dart';
import 'package:dragnet/models/responses/locationhistory_response.dart';
import 'package:dragnet/models/responses/pin_pill_info.dart';
import 'package:dragnet/services/backen_service.dart';
import 'package:dragnet/utils/colors.dart';
import 'package:dragnet/utils/constants.dart';
import 'package:dragnet/utils/service_urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NavigationHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return NavigationHomePageState();
  }
}

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 80;
const double CAMERA_BEARING = 30;
const LatLng SOURCE_LOCATION = LatLng(0, 0);
const LatLng DEST_LOCATION = LatLng(0, 0);

class NavigationHomePageState extends State<NavigationHomePage> {
  var _formKey = GlobalKey<FormState>();
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>();
  Set<Polyline> _polyLines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
  Position currentLocation;
  Position destinationLocation;
  double pinPillPosition = -100;
  PinInformation currentlySelectedPin = PinInformation(
      pinPath: '',
      avatarPath: '',
      location: LatLng(0, 0),
      locationName: '',
      labelColor: Colors.grey);
  PinInformation sourcePinInfo;
  PinInformation destinationPinInfo;
  LatLng sourceLatLng;
  LatLng destinationLatLng;
  GoogleMap maps;
  CameraPosition _initialCamera;
  bool isDirectionEnabled = false;
  String totalDistance = '';
  String totalTime = '';
  bool isCurrentLocationChanged = false;
  final Set<Polyline> polyline = {};
  List<LatLng> routeCoords;
  bool isStartEnabled = false;
  TextEditingController _sourceController = TextEditingController();
  TextEditingController _destinationController = TextEditingController();
  int _userId;
  Timer timer;
  int seconds = 120;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadGlobalValues();
    _currentLocation();

    timer = Timer.periodic(
        Duration(seconds: seconds), (Timer t) => _getCurrentLocation());
    if (isStartEnabled == true) {
      var locationOptions =
          LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
      StreamSubscription<Position> positionStream = geoLocator
          .getPositionStream(locationOptions)
          .listen((Position position) {
        currentLocation = position;
        updatePinOnMap();
        calculateDistance(currentLocation.latitude, currentLocation.longitude,
            destinationLatLng.latitude, destinationLatLng.longitude);
      });
    }
  }

  List<GetLocationHistoryResponse> _locationHistory = List();
  GetLocationHistoryResponse _homeLocation;
  GetLocationHistoryResponse _workLocation;
  void _getLocationHistory() async {
    try {
      http.Response response = await http.get(
        Get_LocationHistory_Url + "$_userId",
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
        },
      );
      int statusCode = response.statusCode;
      if (statusCode == 200) {
        Iterable result = json.decode(response.body);
        List<GetLocationHistoryResponse> itemsList = result
            .map((model) => GetLocationHistoryResponse.fromJson(model))
            .toList();
        for (var item in itemsList) {
          if (item.locationType == 0) {
            _homeLocation = item;
          } else if (item.locationType == 1) {
            _workLocation = item;
          } else {
            _locationHistory.add(item);
          }
        }
        setState(() {
          _locationHistory = _locationHistory;
        });
        print("_locationHistory ${_locationHistory.length}");
      }
    } catch (e) {
      print("_locationHistory $e");
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _loadGlobalValues() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Try reading data from the counter key. If it doesn't exist, return 0.
      _userId = prefs.getInt('UserId') ?? '';
    });
    _getLocationHistory();
  }

  void _updateLocationToCloud() async {
    SendCrimeNotificationModel newPost = new SendCrimeNotificationModel(
        userId: _userId,
        latitude: _currentPosition.latitude.toString(),
        longitude: _currentPosition.latitude.toString());
    SendCrimeNotificationModel p = await sendCrimeNotificationPost(
        Send_Location_Url,
        body: newPost.toMap());
  }

  Future<SendCrimeNotificationModel> sendCrimeNotificationPost(String url,
      {Map body}) async {
    http
        .post(
      url,
      headers: {
        "content-type": "application/json",
        "accept": "application/json",
      },
      body: json.encode(body),
    )
        .then((http.Response response) async {
      final int statusCode = response.statusCode;

      if (statusCode == 200) {
      } else {}
    });
  }

  final Geolocator geoLocator = Geolocator()..forceAndroidLocationManager;
  Position _currentPosition;
  String _currentAddress;
  _getCurrentLocation() {
    geoLocator
        .getCurrentPosition(desiredAccuracy: geo.LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        print(position);
      });

      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geoLocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];
      setState(() {
        _currentAddress =
            "${place.name},${place.thoroughfare},${place.subLocality},${place.locality},${place.administrativeArea},${place.country},${place.postalCode}";
        // _currentTime = "${place.administrativeArea}";
        _updateLocationToCloud();
      });
    } catch (e) {
      print(e);
    }
  }

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'images/source.png');

    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'images/driving_pin.png');
  }

  void calculateDistance(lat1, lon1, lat2, lon2) async {
    try {
      double distanceInMeters =
          await Geolocator().distanceBetween(lat1, lon1, lat2, lon2);
      setState(() {
        distanceInMeters = distanceInMeters / 1000;
        totalDistance = distanceInMeters.toString();
        totalDistance = totalDistance.substring(0, 4) + ' Km';
        double _time = currentLocation.speed;
        double tot = distanceInMeters / _time;
        totalTime = tot.toString();
        totalTime = totalTime.substring(0, 2) + ' mins';
      });
    } catch (e) {
      print("calculateDistance $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Stack(
        children: <Widget>[
          isDirectionEnabled == true ? _buildGoogleMap(context) : SizedBox(),
          Align(
            alignment: Alignment.topCenter,
            child: Form(
              key: _formKey,
              child: Container(
                color: isDirectionEnabled == false
                    ? Colors.white
                    : Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 50,
                    ),
                    Row(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(
                            Icons.keyboard_backspace,
                            color: Colors.black,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Icon(
                          Icons.my_location,
                          size: 22,
                          color: Colors.black,
                        ),
                        Expanded(child: _sourceSearch()),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: 50,
                        ),
                        Icon(
                          Icons.location_on,
                          size: 22,
                          color: Colors.red,
                        ),
                        Expanded(
                          child: _destinationSearch(),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    isDirectionEnabled == false
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              SizedBox(
                                width: 30,
                              ),
                              Flexible(
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.home,
                                      color: Colors.black38,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _currentLocation();
                                        _searchAddress = _homeLocation.address;
                                        setState(() {
                                          _destinationController.text =
                                              _searchAddress;
                                          if (_searchAddress != null) {
                                            isCurrentLocationChanged = true;
                                            isDirectionEnabled = true;
                                            _searchAndNavigateDestination();
                                          }
                                        });
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text("Home"),
                                          Text(
                                            _homeLocation != null
                                                ? _homeLocation.address
                                                    .substring(0, 10)
                                                : "Set Location",
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.black38,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                  height: 30,
                                  child: VerticalDivider(
                                    color: Colors.black12,
                                    thickness: 1,
                                  )),
                              SizedBox(
                                width: 5,
                              ),
                              Flexible(
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.work,
                                      color: Colors.black38,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _currentLocation();
                                        _searchAddress = _homeLocation.address;
                                        setState(() {
                                          _destinationController.text =
                                              _searchAddress;
                                          if (_searchAddress != null) {
                                            isCurrentLocationChanged = true;
                                            isDirectionEnabled = true;
                                            _searchAndNavigateDestination();
                                          }
                                        });
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text("Work"),
                                          Text(
                                            _workLocation != null
                                                ? _workLocation.address
                                                    .substring(0, 10)
                                                : "Set Location",
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.black38,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                  height: 30,
                                  child: VerticalDivider(
                                    color: Colors.black12,
                                    thickness: 1,
                                  )),
                              SizedBox(
                                width: 5,
                              ),
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.edit,
                                    color: Colors.black38,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text("Edit")
                                ],
                              ),
                              SizedBox(
                                width: 30,
                              ),
                            ],
                          )
                        : SizedBox(),
                    isDirectionEnabled == false
                        ? Padding(
                            padding:
                                EdgeInsets.only(left: 30, right: 20, top: 5),
                            child: Divider(
                              thickness: 8,
                              color: Colors.black12,
                            ),
                          )
                        : SizedBox(),
                    isDirectionEnabled == false
                        ? Padding(
                            padding:
                                EdgeInsets.only(left: 30, right: 10, top: 5),
                            child: Text(
                              "Previous Searches",
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontMedium,
                              ),
                            ),
                          )
                        : SizedBox(),
                    isDirectionEnabled == false
                        ? _locationHistoryWidget()
                        : SizedBox()
                  ],
                ),
              ),
            ),
          ),
          //_searchLocation(),
        ],
      ),
      floatingActionButton:
          isDirectionEnabled == true ? _routeFab() : SizedBox(),
    );
  }

  Widget _locationHistoryWidget() {
    return Expanded(
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: _locationHistory.length,
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.only(left: 30, right: 20, top: 5, bottom: 5),
              child: GestureDetector(
                onTap: () {
                  _currentLocation();
                  _searchAddress = _locationHistory[index].address;
                  setState(() {
                    _destinationController.text = _searchAddress;
                    if (_searchAddress != null) {
                      isCurrentLocationChanged = true;
                      isDirectionEnabled = true;
                      _searchAndNavigateDestination();
                    }
                  });
                },
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.watch_later,
                          color: Colors.black38,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Flexible(
                          child: Text(_locationHistory[index].address),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Divider(
                      thickness: 0.7,
                      color: Colors.black12,
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  void _showModalSheetRouteDetails() {
    showModalBottomSheet(
        isDismissible: false,
        //enableDrag: false,
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: false,
        builder: (builder) {
          return SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: new BorderRadius.all(Radius.circular(6.0)),
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
                      child: Text.rich(
                        TextSpan(
                          text: "${totalTime}  ",
                          style: GoogleFonts.poppins(
                              fontSize: 25, color: Colors.orangeAccent),
                          children: <TextSpan>[
                            TextSpan(
                                text: totalDistance,
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  color: Colors.black54,
                                  //decoration: TextDecoration.underline,
                                )),
                            // can add more TextSpans here...
                          ],
                        ),
                      ),
                    ),
                  ),
                  // _buildContainer(),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: <Widget>[
                        _startButton(),
                        _cancelButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _startButton() {
    var startBtn = Padding(
        padding:
            EdgeInsets.only(top: 10.0, bottom: 10.0, left: 15.0, right: 5.0),
        child: SizedBox(
          height: 37.0,
          child: new RaisedButton.icon(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
            ),
            icon: Icon(FontAwesomeIcons.directions),
            color: Color.fromRGBO(24, 133, 239, 1),
            textColor: Colors.white,
            label: Text(
              'Start',
              // textScaleFactor: 1.0,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            onPressed: () async {
              final GoogleMapController controller = await _controller.future;

              setState(() async {
                isDirectionEnabled = true;
                isStartEnabled = true;
                updatePinOnMap();
                Navigator.pop(context);

                controller.animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(
                    bearing: 13,
                    tilt: 5,
                    target:
                        LatLng(sourceLatLng.latitude, sourceLatLng.longitude),
                    zoom: 17.0,
                  ),

                  //_markers.add(current_location),
                ));
              });
            },
          ),
        ));
    return startBtn;
  }

  Widget _cancelButton() {
    var startBtn = Padding(
        padding:
            EdgeInsets.only(top: 10.0, bottom: 10.0, left: 5.0, right: 15.0),
        child: SizedBox(
          //width: 100,
          height: 37.0,
          // height: double.infinity,
          child: new RaisedButton.icon(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
            ),
            icon: Icon(Icons.close),
            color: Color.fromRGBO(27, 29, 77, 1),
            textColor: Colors.white,
            label: Text(
              'Cancel',
              // textScaleFactor: 1.0,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            onPressed: () {
              setState(() async {
                setState(() {
                  _sourceController.text = '';
                  _destinationController.text = '';
                  isStartEnabled = true;
                  Navigator.pop(context);
                  _markers = Set<Marker>();
                  _polyLines = Set<Polyline>();
                  polylineCoordinates = [];
                  polylinePoints = PolylinePoints();
                  _currentLocation();
                });
              });
            },
          ),
        ));
    return startBtn;
  }

  Widget _sourceSearch() {
    return Container(
      height: 50.0,
      margin: EdgeInsets.only(right: 10.0, left: 5),
      child: Material(
        elevation: 6,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: TypeAheadFormField(
          textFieldConfiguration: TextFieldConfiguration(
            maxLines: null,
            enabled: false,
            autofocus: false,
            controller: _sourceController,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black),
            //style: TextStyle(color: Colors.white, fontSize: 17.0),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Your Location',
              hintStyle: TextStyle(
                color: Colors.black54,
                fontSize: 17.0,
              ),
            ),
          ),
          suggestionsCallback: (pattern) async {
            return await BackendService.getSuggestions(pattern);
          },
          itemBuilder: (context, suggestion) {
            return ListTile(
              leading: Icon(Icons.location_on),
              title: Text(suggestion["description"]),
              // subtitle: Text('\$${suggestion['price']}'),
            );
          },
          onSuggestionSelected: (suggestion) {
            _searchAddress = suggestion['description'];
            setState(() {
              _sourceController.text = _searchAddress;
              if (_searchAddress != null) {
                isCurrentLocationChanged = false;
                _searchAndNavigateSource();
              } else {}
            });
          },
        ),
      ),
    );
  }

  Widget _destinationSearch() {
    return Container(
      height: 50.0,
      margin: EdgeInsets.only(top: 10.0, left: 5.0, right: 10.0),
      child: Material(
        elevation: 6,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: TypeAheadFormField(
          textFieldConfiguration: TextFieldConfiguration(
            maxLines: 1,
            autofocus: false,
            controller: _destinationController,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(left: 5, right: 5),
              hintText: 'Choose destination',
              hintStyle: TextStyle(
                color: Colors.black54,
                fontSize: 17.0,
              ),
            ),
          ),
          suggestionsCallback: (pattern) async {
            return await BackendService.getSuggestions(pattern);
          },
          itemBuilder: (context, suggestion) {
            return ListTile(
              leading: Icon(Icons.location_on),
              title: Text(suggestion["description"]),
              // subtitle: Text('\$${suggestion['price']}'),
            );
          },
          onSuggestionSelected: (suggestion) {
            _searchAddress = suggestion['description'];
            setState(() {
              _destinationController.text = _searchAddress;
              if (_searchAddress != null) {
                isCurrentLocationChanged = true;
                _searchAndNavigateDestination();
              } else {}
            });
          },
        ),
      ),
    );
  }

  String _searchAddress;
  void _searchAndNavigateSource() async {
    final GoogleMapController controller = await _controller.future;
    Geolocator().placemarkFromAddress(_searchAddress).then((value) {
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 13,
          //tilt: 0,
          target:
              LatLng(value[0].position.latitude, value[0].position.longitude),
          zoom: 15.0,
        ),

        //_markers.add(current_location),
      ));
      setState(() {
        _markers.removeWhere((m) => m.markerId.value == 'curr_loca');
        sourceLatLng =
            LatLng(value[0].position.latitude, value[0].position.longitude);
        Marker current_location = Marker(
          markerId: MarkerId('curr_loca'),
          position: LatLng(sourceLatLng.latitude, sourceLatLng.longitude),
          infoWindow: InfoWindow(title: 'My Current Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet,
          ),
        );

        controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            bearing: 13,
            //tilt: 0,
            target: LatLng(sourceLatLng.latitude, sourceLatLng.longitude),
            zoom: 15.0,
          ),
          //_markers.add(current_location),
        ));
        //controller.
        setState(() {
          maps.markers;
          _markers.add(current_location);

          _initialCamera = CameraPosition(
            target: LatLng(sourceLatLng.latitude, sourceLatLng.longitude),
            zoom: 10,
          );

          currentlySelectedPin = PinInformation(
              pinPath: '',
              avatarPath: '',
              location: LatLng(sourceLatLng.latitude, sourceLatLng.longitude),
              locationName: '',
              labelColor: Colors.grey);
          _updateLocationToCloud();
        });
      });
    });
  }

  void _searchAndNavigateDestination() async {
    final GoogleMapController controller = await _controller.future;
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    geolocator.placemarkFromAddress(_searchAddress).then((value) {
      _markers.removeWhere((m) => m.markerId.value == 'dest_loca');
      Marker SerachLocation = Marker(
        markerId: MarkerId('dest_loca'),
        position:
            LatLng(value[0].position.latitude, value[0].position.longitude),
        onTap: () {
          setState(() {
            isDirectionEnabled = true;
          });
        },
        infoWindow: InfoWindow(title: 'My Destination'),
        icon: destinationIcon,
      );

      destinationLatLng =
          LatLng(value[0].position.latitude, value[0].position.longitude);
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 13,
          //tilt: 0,
          target:
              LatLng(value[0].position.latitude, value[0].position.longitude),
          zoom: 15.0,
        ),
      ));
      setState(() {
        setMapPins();
        showPinsOnMap();
        calculateDistance(sourceLatLng.latitude, sourceLatLng.longitude,
            destinationLatLng.latitude, destinationLatLng.longitude);
        _showModalSheetRouteDetails();
      });
    });

    print("Source $sourceLatLng");
    print("destination $destinationLatLng");
  }

  Widget _fab() {
    return Material(
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
            //showPinsOnMap();
          });
        },
      ),
    );
  }

  Widget _routeFab() {
    return Material(
      elevation: 4.0,
      shape: CircleBorder(),
      clipBehavior: Clip.hardEdge,
      color: Colors.blue,
      child: IconButton(
        icon: Icon(
          Icons.clear,
          color: Colors.white,
        ),
        onPressed: () {
          setState(() {
            isDirectionEnabled = false;
            _sourceController.text = '';
            _destinationController.text = '';
            isStartEnabled = true;
            //Navigator.pop(context);
            _markers = Set<Marker>();
            _polyLines = Set<Polyline>();
            polylineCoordinates = [];
            polylinePoints = PolylinePoints();
            _currentLocation();
          });
        },
      ),
    );
  }

  Widget _buildGoogleMap(BuildContext context) {
    CameraPosition initialLocation = CameraPosition(
        zoom: CAMERA_ZOOM,
        bearing: CAMERA_BEARING,
        tilt: CAMERA_TILT,
        target: SOURCE_LOCATION);
    maps = GoogleMap(
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
      tiltGesturesEnabled: false,
      markers: _markers,
      polylines: _polyLines,
      mapType: MapType.normal,
      initialCameraPosition: initialLocation,
//      onTap: (LatLng loc) {
//        pinPillPosition = -100;
//      },
      //circles: circles,
      onMapCreated: onMapCreated,
    );

    return maps;
  }

  void onMapCreated(GoogleMapController controller) {
    //controller.setMapStyle(Utils.mapStyles);
    _controller.complete(controller);
    //_drawRoutes();
  }

  void setMapPins() {
    try {
      setState(() {
        // source pin
        _markers.removeWhere((m) => m.markerId.value == 'curr_loca');
        _markers.add(Marker(
            markerId: MarkerId('sourcePin'),
            position: sourceLatLng,
            icon: sourceIcon));
        // destination pin
        _markers.add(Marker(
            markerId: MarkerId('destPin'),
            position: destinationLatLng,
            icon: destinationIcon));
      });
    } catch (e) {
      print("setMapPins $e");
    }
  }

  void _currentLocation() async {
    try {
      final GoogleMapController controller = await _controller.future;
      print("_currentLocation entered");
      final Geolocator geolocator = Geolocator()
        ..forceAndroidLocationManager = true;
      bool isLocationEnabled = await geolocator.isLocationServiceEnabled();
      Position position = await geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
      print("_currentLocation position $position");
      _currentPosition = position;
      currentLocation = _currentPosition;
      sourceLatLng =
          LatLng(_currentPosition.latitude, _currentPosition.longitude);
      print("_currentLocation ${position.latitude}");
      print("_currentLocation ${position.longitude}");
      // the trick is to remove the marker (by id)
      // and add it again at the updated location
      _markers.removeWhere((m) => m.markerId.value == 'curr_loca');
      Marker current_location = Marker(
        markerId: MarkerId('curr_loca'),
        position: LatLng(sourceLatLng.latitude, sourceLatLng.longitude),
        infoWindow: InfoWindow(title: 'My Current Location'),
        icon: sourceIcon,
      );

      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 13,
          tilt: 5,
          target: LatLng(sourceLatLng.latitude, sourceLatLng.longitude),
          zoom: 17.0,
        ),
        //_markers.add(current_location),
      ));
      //controller.
      setState(() {
        maps.markers;
        _markers.add(current_location);

        _initialCamera = CameraPosition(
          target: LatLng(sourceLatLng.latitude, sourceLatLng.longitude),
          zoom: 10,
        );

        currentlySelectedPin = PinInformation(
            pinPath: '',
            avatarPath: '',
            location: LatLng(sourceLatLng.latitude, sourceLatLng.longitude),
            locationName: '',
            labelColor: Colors.grey);
        _updateLocationToCloud();
      });
    } catch (e) {
      print("_currentLocation $e");
    }
  }

  void showPinsOnMap() async {
    try {
      setSourceAndDestinationIcons();
      var pinPosition = LatLng(sourceLatLng.latitude, sourceLatLng.longitude);
      var destPosition =
          LatLng(destinationLatLng.latitude, destinationLatLng.longitude);

      sourcePinInfo = PinInformation(
          locationName: "Start Location",
          location: pinPosition,
          pinPath: "images/driving_pin.png",
          avatarPath: "images/driving_pin.png",
          labelColor: Colors.blueAccent);

      destinationPinInfo = PinInformation(
          locationName: "End Location",
          location: destPosition,
          pinPath: "images/destination_map_marker.png",
          avatarPath: "images/driving_pin.png",
          labelColor: Colors.purple);

      _markers.add(Marker(
          markerId: MarkerId('sourcePin'),
          position: pinPosition,
          onTap: () {
            setState(() {
              currentlySelectedPin = sourcePinInfo;
              pinPillPosition = 0;
            });
          },
          icon: sourceIcon));
      _markers.add(Marker(
          markerId: MarkerId('destPin'),
          position: destPosition,
          onTap: () {
            setState(() {
              currentlySelectedPin = destinationPinInfo;
              pinPillPosition = 0;
            });
          },
          icon: destinationIcon));
      setPolyLines();
    } catch (e) {
      print("showPinsOnMap $e");
    }
  }

  void setPolyLines() async {
    try {
      debugPrint(
          "SourceLatLng ${sourceLatLng.latitude + sourceLatLng.longitude}");
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        GoogleAPIKey,
        PointLatLng(sourceLatLng.latitude, sourceLatLng.longitude),
        PointLatLng(destinationLatLng.latitude, destinationLatLng.longitude),
        travelMode: TravelMode.driving,
      );
      if (result.points.isNotEmpty) {
        print("result Value ${result}");
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      } else {
        _errorAlert(context, "Failed");
      }

      setState(() {
        _polyLines.add(Polyline(
            geodesic: true,
            width: 5, // set the width of the polylines
            polylineId: PolylineId("poly_routes"),
            color: RouteLineColor,
            points: polylineCoordinates));
      });
    } catch (e) {
      _errorAlert(context, "Catch ${e}");
      print("setPolyLines $e");
    }
  }

  void updatePinOnMap() async {
    // create a new CameraPosition instance
    // every time the location changes, so the camera
    // follows the pin as it moves with an animation
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    // do this inside the setState() so Flutter gets notified
    // that a widget update is due
    setState(() {
      // updated position
      var pinPosition =
          LatLng(currentLocation.latitude, currentLocation.longitude);

      sourcePinInfo.location = pinPosition;

      // the trick is to remove the marker (by id)
      // and add it again at the updated location
      _markers.removeWhere((m) => m.markerId.value == 'curr_loca');
      _markers.add(Marker(
          markerId: MarkerId('curr_loca'),
          onTap: () {
            setState(() {
              currentlySelectedPin = sourcePinInfo;
              pinPillPosition = 0;
            });
          },
          position: pinPosition, // updated position
          icon: sourceIcon));
    });
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
}
