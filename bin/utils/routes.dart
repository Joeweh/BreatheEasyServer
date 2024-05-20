import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

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
      'travelMode': 'DRIVE',
      'polylineQuality': 'HIGH_QUALITY',
      'computeAlternativeRoutes': true
    };

    var response = await http.post(url, headers: headers, body: jsonEncode(body));

    return response;
  }
}

class Route {
  static const metersToMiles = 1609.34;
  static const secondsToMinutes = 60.0;

  late double distanceMiles;
  late double durationMinutes;
  late String polylineId;
  late List<NavigationInstruction> instructions;

  Route({ required this.distanceMiles, required this.durationMinutes, required this.polylineId, required this.instructions });

  factory Route.fromJson(Map<String, dynamic> json) {
    var distanceMeters = json['distanceMeters'] as int;
    var durationString = json['staticDuration'] as String;

    var durationSeconds = double.parse(durationString.substring(0, durationString.length - 1));

    var routeLegs = json['legs'];

    var navInstructions = <NavigationInstruction>[];

    for (var leg in routeLegs) {
      var legSteps = leg['steps'];

      for (var step in legSteps) {
        var stepInstructions = step['navigationInstruction'];

        navInstructions.add(NavigationInstruction.fromJson(stepInstructions));
      }
    }

    return Route(
        distanceMiles: distanceMeters / metersToMiles,
        durationMinutes: durationSeconds / secondsToMinutes,
        polylineId: json['polyline']['encodedPolyline'],
        instructions: navInstructions
    );
  }

  Map<String, dynamic> toJson() => {
    'distanceMiles': distanceMiles,
    'durationMinutes': durationMinutes,
    'polylineId': polylineId,
    'navInstructions': instructions
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