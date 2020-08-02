import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:http/http.dart' as http;

const baseUrl = "https://jsonplaceholder.typicode.com";

class API {
  static Future getAPI(String url, String accessToken) {
    if (accessToken != "") {
      return http.get(
        Uri.encodeFull(url),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          'Authorization': 'Bearer $accessToken',
        },
      );
    } else {
      return http.get(
        Uri.encodeFull(url),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
        },
      );
    }
  }

  static Future postAPI(String url, String accessToken, Map body) {
    if (accessToken != "") {
      return http.post(
        Uri.encodeFull(url),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );
    } else {
      return http.post(
        Uri.encodeFull(url),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
        },
        body: jsonEncode(body),
      );
    }
  }

  static Future putAPI(String url, String accessToken, Map body) {
    if (accessToken != "") {
      return http.put(
        Uri.encodeFull(url),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );
    } else {
      return http.put(
        Uri.encodeFull(url),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
        },
        body: jsonEncode(body),
      );
    }
  }

  static Future deleteAPI(String url, String accessToken) {
    return http.delete(
      Uri.encodeFull(url),
      headers: {
        "content-type": "application/json",
        "accept": "application/json",
        'Authorization': 'Bearer $accessToken',
      },
    );
  }

  static Future deleteWithBodyAPI(String url, String accessToken, Map body) {
    final _url = Uri.parse(url);
    final request = http.Request("DELETE", _url);
    request.headers.addAll(
      <String, String>{
        "content-type": "application/json",
        "accept": "application/json",
        'Authorization': 'Bearer $accessToken',
      },
    );
    request.body = jsonEncode(body);
    return request.send();
  }

  static Future uploadImageAPI(
      String url, File _image, String imagePath, String fileName) async {
    var uri = Uri.parse(url);
    http.MultipartRequest request = new http.MultipartRequest('POST', uri);
    http.ByteStream(DelegatingStream.typed(_image.openRead()));
    await _image.length();
    var multipartFile = await http.MultipartFile.fromPath("file", imagePath,
        filename: fileName);
    request.files.add(multipartFile);
    return request.send();
  }
}
