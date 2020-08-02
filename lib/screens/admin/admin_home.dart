import 'dart:convert';

import 'package:dragnet/models/admin/response/admin_crimeResponse.dart';
import 'package:dragnet/screens/admin/add_new_crime.dart';
import 'package:dragnet/services/api_services.dart';
import 'package:dragnet/utils/Utility.dart';
import 'package:dragnet/utils/colors.dart';
import 'package:dragnet/utils/service_urls.dart';
import 'package:dragnet/widgets/custom_profile_image.dart';
import 'package:dragnet/widgets/custom_progress_bar.dart';
import 'package:dragnet/widgets/empty_error_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
class AdminHome extends StatefulWidget {
  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  bool _isRecent = true;
  var _searchController = TextEditingController();
  bool _isActive = false;
  bool _isPending = false;
  bool _isCompleted=false;
  bool _isLoading = false;
  final text_tab_style=GoogleFonts.poppins(
    color: Colors.black,
    fontWeight: FontWeight.bold
  );
  String Error_No_Internet_Test="Unable to connect, Please Check Internet Connection";

  List<AdminCrimeResponse> filteredUser = List();
  List<AdminCrimeResponse> _searchResult = List();
  List<AdminCrimeResponse> filteredActive = List();
  List<AdminCrimeResponse> filterdPending = List();
  List<AdminCrimeResponse> filteredCompleted = List();

 @override
  void initState() {
   _getLoginData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return AddNewCrime();
              },
            ),
          );
        },
        backgroundColor: Color.fromRGBO(27, 29, 77, 1),
        child: Image.asset("images/crime_15.jpg",width: 30,height: 30,),
      ),
      backgroundColor: Colors.white,
        body: CustomProgressBar(
          isLoading: _isLoading,
          widget:Container(color: Colors.white,
          padding: EdgeInsets.only(left: 10,right: 10,top: 12),
           child: ListView(
          physics: ClampingScrollPhysics(), // new
          shrinkWrap: true,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.menu,size: 30,),
                    SizedBox(height: 4,),
                    Row(
                      children: [
                        Text("Hello, ",style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                        ),),
                        Text("Santosh",style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black
                        ),),
                      ],
                    )
                  ],
                ),
                CustomProfileImage(
                  url: "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcSZdk53HvbHwvWZuUKtf30nUTPI-DzKTga7bQ&usqp=CAU",
                  radius: 30,
                )
              ],
            ),
            SizedBox(height: 32,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 105,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(7, 28, 216, 1),
                    borderRadius:BorderRadius.only(topRight: Radius.circular(25))
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text('34',style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.white
                        ),),
                      ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text('Total cases',style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white
                      ),),
                        )
                    ],
                  ),
                ),
                Container(
                  width: 105,
                  height: 100,
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(17, 208, 222, 1),
                      borderRadius:BorderRadius.only(topRight: Radius.circular(25))
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text('34',style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.white
                        ),),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text('Active cases',style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white
                        ),),
                      )
                    ],
                  ),
                ),
                Container(
                  width: 105,
                  height: 100,
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(239, 161, 27, 1),
                      borderRadius:BorderRadius.only(topRight: Radius.circular(25))
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text('34',style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.white
                        ),),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text('Pending cases',style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white
                        ),),
                      )
                    ],
                  ),
                ),

              ],
            ),
            SizedBox(height: 24,),
            _searchBar(),
            SizedBox(height: 24,),
            _customTab(),
            SizedBox(height: 1,),
            _showData()
          ],
        ),),

      ),
    );
  }

  Widget _searchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Color.fromRGBO(241, 241, 241, 1),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintStyle: TextStyle(fontSize: 18,color: Colors.grey),
          hintText: 'Search....',
          suffixIcon: Icon(
            Icons.search,
            color: Colors.grey,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        onChanged: (string) {
          onSearchTextChanged(string);
        },
      ),
    );
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text == "") {
      setState(() {});
      return;
    }
    if (_isRecent) {
      filteredUser.forEach((item) {
        var itemName = item.crimeName.toUpperCase();
        if (itemName.contains(text.toUpperCase())) {
          _searchResult.add(item);
        }
      });
      setState(() {
        _searchResult = _searchResult;
      });
    } else if(_isActive){
      filteredActive.forEach((item) {
        var itemName = item.crimeName.toUpperCase();
        if (itemName.contains(text.toUpperCase())) {
          _searchResult.add(item);
        }
      });
      setState(() {
        _searchResult = _searchResult;
      });
    }else if(_isPending)
    {
      filterdPending.forEach((item) {
        var itemName = item.crimeName.toUpperCase();
        if (itemName.contains(text.toUpperCase())) {
          _searchResult.add(item);
        }
      });
      setState(() {
        _searchResult = _searchResult;
      });
    }else
      {
        filteredCompleted.forEach((item) {
          var itemName = item.crimeName.toUpperCase();
          if (itemName.contains(text.toUpperCase())) {
            _searchResult.add(item);
          }
        });
        setState(() {
          _searchResult = _searchResult;
        });
      }
  }
  Widget _customTab() {
    return Container(
      height: 50,
      margin: EdgeInsets.only(left: 0, right: 0),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  //hide the keyboard
                  FocusScope.of(context).requestFocus(FocusNode());
                  setState(() {
                    _isRecent = true;
                    _isActive = false;
                    _isPending = false;
                    _isCompleted=false;
                    _searchController.text = "";
                  });
                  bool connectionResult = await Utility.checkConnection();
                  if (connectionResult) {
                     await _getRecent();
                  } else {
                    Utility.showToast(context, Error_No_Internet_Test);
                  }
                },
                child: _isRecent
                    ? _getButton("Recent")
                    : _getunselectButton('Recent'),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  //hide the keyboard
                  FocusScope.of(context).requestFocus(FocusNode());
                  setState(() {
                    _isRecent = false;
                    _isActive = true;
                    _isPending = false;
                    _isCompleted=false;
                    _searchController.text = "";
                  });
                  bool connectionResult = await Utility.checkConnection();
                  if (connectionResult) {
                    await _getActive();
                  } else {
                    Utility.showToast(context, Error_No_Internet_Test);
                  }
                },
                child: _isActive
                    ? _getButton('Active')
                    : _getunselectButton('Active'),
              ),
            ),

            Expanded(
              child: GestureDetector(
                onTap: () async {
                  //hide the keyboard
                  FocusScope.of(context).requestFocus(FocusNode());
                  setState(() {
                    _isRecent = false;
                    _isPending = true;
                    _isActive = false;
                    _isCompleted=false;
                    _searchController.text = "";
                  });
                  bool connectionResult = await Utility.checkConnection();
                  if (connectionResult) {
                    await _getPending();
                  } else {
                    Utility.showToast(context, Error_No_Internet_Test);
                  }
                },
                child:_isPending
                    ? _getButton('Pending')
                    : _getunselectButton('Pending'),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  //hide the keyboard
                  FocusScope.of(context).requestFocus(FocusNode());
                  setState(() {
                    _isRecent = false;
                    _isActive = false;
                    _isPending = false;
                    _isCompleted=true;
                    _searchController.text = "";
                  });
                  bool connectionResult = await Utility.checkConnection();
                  if (connectionResult) {
                     await _getCompleted();
                  } else {
                    Utility.showToast(context, Error_No_Internet_Test);
                  }
                },
                child: _isCompleted
                    ? _getButton("Completed")
                    : _getunselectButton('Completed'),
              ),
            ),

          ],
        ),
        Divider(color: Color.fromRGBO(200, 200, 200, 1),)
      ],)
    );
  }
  
  Widget _getButton(String txt)
  {
     return Container(
       padding: EdgeInsets.only(right: 12,left: 12),
       decoration: BoxDecoration(
         borderRadius: BorderRadius.circular(6),
         color: Colors.black,
       ),
       width: 80,
       height: 30,
       child: Center(
         child: Text("$txt",style: GoogleFonts.poppins(
             color: Colors.white,
                 fontSize: 12
         ),),
       )
     );
  }

  Widget _getunselectButton(String txt)
  {
    return Container(
        padding: EdgeInsets.only(right: 6,left: 6),
        width: 80,
        height: 30,
        child: Center(
          child: Text("$txt",style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14
          ),),
        )
    );
  }
  Future _getRecent() async {
    try {
      setState(() {
        _isLoading = true;
      });
      var url = Base_Url + "Crime/Crimes";

      API.getAPI(url, '').then((response) async {
        int statusCode = response.statusCode;
        setState(() {
          _isLoading = false;
        });
        print(response.body);
        if (statusCode == 200) {
          var responseJson = json.decode(response.body);
          var listJson = responseJson['data'];
          setState(() {
            filteredUser = List<AdminCrimeResponse>.from(
                listJson.map((i) => AdminCrimeResponse.fromJson(i)));
          });
        }
      });
    } catch (e) {
      print("_getAllCourses $e");
    }
  }
  Future _getActive() async {
    try {
      setState(() {
        _isLoading = true;
      });
      var url = Base_Url + "Crime/Crimes?crimeStatus=Active";

      API.getAPI(url, '').then((response) async {
        int statusCode = response.statusCode;
        setState(() {
          _isLoading = false;
        });
        print(response.body);
        if (statusCode == 200) {
          var responseJson = json.decode(response.body);
          var listJson = responseJson['data'];
          setState(() {
            filteredActive = List<AdminCrimeResponse>.from(
                listJson.map((i) => AdminCrimeResponse.fromJson(i)));
          });
        }
      });
    } catch (e) {
      print("_getAllCourses $e");
    }
  }
  Future _getPending() async {
    try {
      setState(() {
        _isLoading = true;
      });
      var url = Base_Url + "Crime/Crimes?crimeStatus=Pending";

      API.getAPI(url, '').then((response) async {
        int statusCode = response.statusCode;
        setState(() {
          _isLoading = false;
        });
        print(response.body);
        if (statusCode == 200) {
          var responseJson = json.decode(response.body);
          var listJson = responseJson['data'];
          setState(() {
            filterdPending = List<AdminCrimeResponse>.from(
                listJson.map((i) => AdminCrimeResponse.fromJson(i)));
          });
        }
      });
    } catch (e) {
      print("_getAllCourses $e");
    }
  }
  Future _getCompleted() async {
    try {
      setState(() {
        _isLoading = true;
      });
      var url = Base_Url + "Crime/Crimes?crimeStatus=Completed";

      API.getAPI(url, '').then((response) async {
        int statusCode = response.statusCode;
        setState(() {
          _isLoading = false;
        });
        print(response.body);
        if (statusCode == 200) {
          var responseJson = json.decode(response.body);
          var listJson = responseJson['data'];
          setState(() {
            filteredCompleted = List<AdminCrimeResponse>.from(
                listJson.map((i) => AdminCrimeResponse.fromJson(i)));
          });
        }
      });
    } catch (e) {
      print("_getAllCourses $e");
    }
  }
  Widget _showData() {
    var listView;
    if (_isRecent) {
      listView = _searchController.text.isNotEmpty
          ? _searchResult.length != 0
          ? _dynamicListView(_searchResult,)
          : _errorWidget("No Crimes found")
          : filteredUser.length != 0
          ? _dynamicListView(filteredUser,)
          : _errorWidget("No Crimes found");
    } else if (_isActive) {
      listView = _searchController.text.isNotEmpty
          ? _searchResult.length != 0
          ? _dynamicListView(_searchResult)
          : _errorWidget("No Active Crimes Found")
          : filteredActive.length != 0
          ? _dynamicListView(filteredActive)
          : _errorWidget("No Active Crimes Found");
    } else if (_isPending){
      listView = _searchController.text.isNotEmpty
          ? _searchResult.length != 0
          ? _dynamicListView(_searchResult)
          : _errorWidget("No Pending Crimes Found")
          : filterdPending.length != 0
          ? _dynamicListView(filterdPending)
          : _errorWidget("No Pending Crimes Found");
    }else
      {
        listView = _searchController.text.isNotEmpty
            ? _searchResult.length != 0
            ? _dynamicListView(_searchResult)
            : _errorWidget("No Completed Crimes Found")
            : filteredCompleted.length != 0
            ? _dynamicListView(filteredCompleted)
            : _errorWidget("No Completed Crimes Found");
      }
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.only(bottom: 6),
        child: listView,
      ),
    );
  }
  

  Widget _errorWidget(String error) {
    return CustomEmptyErrorCard(
      errorMsg: error,
      errorTestStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontRegular,
          color: Color.fromRGBO(71, 71, 71, 1)
      ),
    );
  }

  Future<void> _getLoginData() async {
    final sharedPref = await SharedPreferences.getInstance();
    setState(() {
//      this.name = sharedPref.getString('firstName') ?? "";
//      this.uid = sharedPref.getString('userId');
//      this.profileImage = sharedPref.getString('profileImage');
//      this.accessToken = sharedPref.getString("accessToken");
//      print(uid);
    });
    bool connectionResult = await Utility.checkConnection();
    if (connectionResult) {
      await _getRecent();
    } else {
      Utility.showToast(context, Error_No_Internet_Test);
    }
  }

  Widget _dynamicListView(List<AdminCrimeResponse> recent)
  {
     return ListView.builder(
       shrinkWrap: true,
         physics: ClampingScrollPhysics(),
       itemCount: recent==null?0:recent.length,
         itemBuilder: (context ,index)
     {
        return GestureDetector(
          onTap: (){
            _showDialog(recent[index]);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: _getColor(recent[index].crimeStatus)
            ),
            margin: EdgeInsets.only(left: 12,right: 12,top: 12),
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(recent[index].crimeName,style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16
                ),),
                SizedBox(height: 6,),
                Text(recent[index].occurrenceAddress,style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    fontSize: 12
                ),),
                SizedBox(height: 6,),
                Text(recent[index].timeOfOccurence,style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                    fontSize: 10
                ),),
                Divider(
                  height: 20.0,
                  thickness: 1,
                  indent: 5.0,
                  color: _getLineColor(recent[index].crimeStatus),
                ),
                Align(
                  alignment:Alignment.bottomRight,
                  child: Text(recent[index].crimeStatus,style: GoogleFonts.poppins(
                      color: _getLineColor(recent[index].crimeStatus),
                      fontWeight: FontWeight.bold,
                      fontSize: 14
                  ),),
                )
              ],
            ),
          ),
        );
     });
  }

  Color _getColor(String status)
  {
    if(status=="Pending")
    {
      return Color.fromRGBO(248, 236, 216, 1);
    }
    else if(status=="Active")
    {
      return Color.fromRGBO(227, 246, 248, 1);
    }
    else
    {
      return Color.fromRGBO(213, 216, 244, 1);
    }
  }
  Color _getLineColor(String status)
  {
     if(status=="Pending")
       {
         return Color.fromRGBO(239, 161, 27, 1);
       }
     else if(status=="Active")
     {
       return Color.fromRGBO(17, 208, 222, 1);
     }
     else
     {
       return Color.fromRGBO(7, 28, 216, 1);
     }
  }

  void _showDialog(AdminCrimeResponse items) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Alert Dialog title"),
          content: ListView(
            children: [
               Text(items.createdByName),
              SizedBox(height: 12,),
              Text(items.occurrenceAddress),
              SizedBox(height: 12,),
              Text(items.crimeDescription),
              SizedBox(height: 12,),
              Text(items.createdByName),
              SizedBox(height: 12,),
              Text(items.createdByName),
              SizedBox(height: 12,),
              Text(items.createdByName),
              SizedBox(height: 12,),
            ],
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
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
