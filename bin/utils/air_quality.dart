import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'places.dart';

class AirQuality {
  static final mapsKey = Platform.environment['MAPS_API_KEY'];

  static Future<http.Response> getCurrentConditions(LatLng location) async {
    var url = Uri.https('airquality.googleapis.com', '/v1/forecast:lookup',
        {'key': '$mapsKey'});

    var headers = {'Content-Type': 'application/json'};

    var body = {
      "universalAqi": true,
      "location": {
        "latitude": location.latitude,
        "longitude": location.longitude
      },
      'dateTime': DateTime.now().toIso8601String()
    };

    var response =
        await http.post(url, headers: headers, body: jsonEncode(body));

    print(response.statusCode);
    print(response.body);

    return response;
  }
}
