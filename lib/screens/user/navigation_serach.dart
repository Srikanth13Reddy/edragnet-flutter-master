import 'package:dragnet/services/backen_service.dart';
import 'package:dragnet/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class NavigationSearch extends StatefulWidget {
  @override
  _NavigationSearchState createState() => _NavigationSearchState();
}

class _NavigationSearchState extends State<NavigationSearch> {
  String googleAPIKey = 'AIzaSyBZU7X97LNq3k6cjg_AmYRofm8-wj8n5_k';
  var _formKey = GlobalKey<FormState>();
  TextEditingController _fromController = TextEditingController();
  TextEditingController _toController = TextEditingController();
  String _fromSearchAddress;
  String _toSearchAddress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            _fromAutoSearch(),
          ],
        ),
      ),
    );
  }

  Widget _fromAutoSearch() {
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
      child: TypeAheadFormField(
        textFieldConfiguration: TextFieldConfiguration(
          textAlign: TextAlign.center,
          controller: _fromController,
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
          _fromSearchAddress = suggestion['description'];
          setState(() {
            _fromController.text = _fromSearchAddress;
            if (_fromSearchAddress != null) {
              // _searchAndNavigate();
            } else {}
          });
        },
      ),
    );
  }
}
