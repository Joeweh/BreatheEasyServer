import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'air_quality.dart';
import 'places.dart';

class Routes {
  static final mapsKey = Platform.environment['MAPS_API_KEY'];

  static Future<http.Response> getRoutes(String originAddress, String destinationAddress) async {
    var url = Uri.https('routes.googleapis.com', '/directions/v2:computeRoutes');

    var headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': '$mapsKey',
      'X-Goog-FieldMask': 'routes.staticDuration,routes.distanceMeters,routes.polyline,routes.legs'
    };

    var body = {
      'origin': {
        'address': originAddress
      },
      'destination': {
        'address': destinationAddress
      },
      'travelMode': 'WALK',
      'polylineQuality': 'HIGH_QUALITY',
      'polylineEncoding': 'GEO_JSON_LINESTRING',
      'computeAlternativeRoutes': true,
      'languageCode': 'en-US'
    };

    var response = await http.post(url, headers: headers, body: jsonEncode(body));

    return response;
  }
}

class Route {
  static const metersToMiles = 1609.34;
  static const secondsToMinutes = 60.0;

  late double airScore;
  late double distanceMiles;
  late double durationMinutes;
  late List<LatLng> polylineCoords;
  late List<NavigationInstruction> instructions;

  Route({ required this.airScore, required this.distanceMiles, required this.durationMinutes, required this.polylineCoords, required this.instructions });

  static Future<Route> fromJson(Map<String, dynamic> json) async {
    var distanceMeters = json['distanceMeters'] as int;
    var durationString = json['staticDuration'] as String;

    var durationSeconds = double.parse(durationString.substring(0, durationString.length - 1));

    var leg = json['legs'][0];

    var navInstructions = <NavigationInstruction>[];

    var steps = leg['steps'];

    var stepsCoords = <LatLng>[];

    var counter = 0;

    for (var step in steps) {
      Map<String, dynamic>? stepInstructions = step['navigationInstruction'];

      if (stepInstructions != null) {
        navInstructions.add(NavigationInstruction.fromJson(stepInstructions));
      }

      LatLng startPoint = LatLng.fromJson(step['startLocation']['latLng']);
      LatLng endPoint = LatLng.fromJson(step['endLocation']['latLng']);

      stepsCoords.add(startPoint);

      if (counter == steps.length - 1) {
        stepsCoords.add(endPoint);
      }
    }

    var coords = json['polyline']['geoJsonLinestring']['coordinates'];

    var coordList = <LatLng>[];

    for (var coordPair in coords) {
      var latLong = LatLng(latitude: coordPair[1], longitude: coordPair[0]);

      coordList.add(latLong);
    }

    var score = await AirQuality.calculateAirQualityScore(stepsCoords);

    return Route(
        airScore: score,
        distanceMiles: distanceMeters / metersToMiles,
        durationMinutes: durationSeconds / secondsToMinutes,
        polylineCoords: coordList,
        instructions: navInstructions
    );
  }

  Map<String, dynamic> toJson() => {
    'airScore': airScore,
    'distanceMiles': distanceMiles,
    'durationMinutes': durationMinutes,
    'navInstructions': instructions,
    'polylineCoords': polylineCoords
  };
}

class NavigationInstruction {
  late String maneuver;
  late String text;

  NavigationInstruction({ required this.maneuver, required this.text });

  factory NavigationInstruction.fromJson(Map<String, dynamic> json) {
    return NavigationInstruction(maneuver: json['maneuver'], text: json['instructions']);
  }

  Map<String, dynamic> toJson() => {
    'maneuver': maneuver,
    'text': text
  };
}