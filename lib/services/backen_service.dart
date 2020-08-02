import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class BackendService {
  static List data;
  static Future<List> getSuggestions(String query) async {
    await Future.delayed(Duration(seconds: 1));
    _autocompletePlace(query);
    print('data ${data}');
    return data;
  }

  static void _autocompletePlace(String input) async {
    /// Will be called everytime the input changes. Making callbacks to the Places
    /// Api and giving the user Place options

    if (input.length > 0) {
      String url =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=${'AIzaSyBZU7X97LNq3k6cjg_AmYRofm8-wj8n5_k'}&language=${'en'}";
//      url +=
//          "&location=${currentLocation.latitude},${currentLocation.longitude}&radius=${3000}";
//        if (widget.strictBounds) {
//          url += "&strictbounds";
//        }
      final response = await http.get(url);
      final jsonData = json.decode(response.body);
      // final json = json.(response.body);
      print('jsonData ${jsonData}');
      print(response.statusCode);
      if (jsonData["error_message"] != null) {
        var error = jsonData["error_message"];
        if (error == "This API project is not authorized to use this API.")
          error +=
              " Make sure the Places API is activated on your Google Cloud Platform";
        throw Exception(error);
      } else {
        var extractdata = json.decode(response.body);
        data = extractdata["predictions"];
      }
    } else {
      return null;
    }
  }
}
