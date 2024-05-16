import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';

class Places {
  static final mapsKey = Env.vars['MAPS_API_KEY'];

  static Future<http.Response> getAutocomplete(String query, LatLong location) async {
    var url = Uri.https('places.googleapis.com', '/v1/places:autocomplete');

    var headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': '$mapsKey'
    };

    var body = {
      'input': query,
      'locationBias': {
        'circle': {
          'center': {
            'latitude': location.latitude,
            'longitude': location.longitude
          },
          'radius': 1.0
        }
      }
    };

    var response = await http.post(url, headers: headers, body: jsonEncode(body));

    return response;
  }
}

class LatLong {
  late double latitude;
  late double longitude;

  LatLong({ required this.latitude, required this.longitude });

  Map<String, double> toJson() => {
    'lat': latitude,
    'long': longitude
  };
}

class PlacePrediction {
  late String id;
  late String name;
  late String address;

  PlacePrediction({ required this.id, required this.name, required this.address });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {

    var innerJson = json['placePrediction'];

    print(innerJson);

    var parsedPlaceId = innerJson['placeId'];

    var a = innerJson['structuredFormat'];

    var parsedName = a['mainText']['text'];

    var parsedAddress = a['secondaryText']['text'];

    return PlacePrediction(
        id: parsedPlaceId,
        name: parsedName,
        address: parsedAddress
    );
  }

  Map<String, String> toJson() => {
    'id': id,
    'name': name,
    'address': address,
  };
}