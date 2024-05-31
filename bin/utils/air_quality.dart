import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;

import 'places.dart';

class AirQuality {
  static const degToRadians = pi / 180.0;
  static const earthRadiusMiles = 3956;

  static final mapsKey = Platform.environment['MAPS_API_KEY'];

  static Future<http.Response> getCurrentConditions(LatLng location) async {
    var url = Uri.https('airquality.googleapis.com', '/v1/currentConditions:lookup',
        {'key': '$mapsKey'});

    var headers = {'Content-Type': 'application/json'};

    var body = {
      "universalAqi": true,
      "location": {
        "latitude": location.latitude,
        "longitude": location.longitude
      },
    };

    var response = await http.post(url, headers: headers, body: jsonEncode(body));

    return response;
  }

  static Future<double> calculateAirQualityScore(List<LatLng> coords) async {
    if (coords.isEmpty) {
      return -1.0;
    }

    var totalScore = 0.0;

    final counterStep = max(1, coords.length / 15).truncate();

    for (var i = 0; i < coords.length; i += counterStep) {
      var response = await AirQuality.getCurrentConditions(coords[i]);

      var body = jsonDecode(response.body);

      var aqi = body['indexes'][0]['aqi'];

      if (aqi > 80) {
        totalScore += 0;
      }

      else if (aqi > 60) {
        totalScore += 1;
      }

      else if (aqi > 40) {
        totalScore += 3;
      }

      else if (aqi > 20) {
        totalScore += 10;
      }

      else {
        totalScore += 20;
      }
    }

    return totalScore / (coords.length / counterStep);
  }
}
