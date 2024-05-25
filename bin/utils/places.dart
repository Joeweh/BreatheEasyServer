import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class Places {
  static final mapsKey = Platform.environment['MAPS_API_KEY'];

  static Future<http.Response> getAutocomplete(String query, LatLng location) async {
    var url = Uri.https('places.googleapis.com', '/v1/places:searchText');

    var headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': '$mapsKey',
      'X-Goog-FieldMask': 'places.id,places.displayName,places.formattedAddress'
    };


    var body = {
      'textQuery': query,
      'locationBias': {
        'circle': {
          'center': {
            'latitude': location.latitude,
            'longitude': location.longitude
          },
          'radius': 500.0
        }
      },
      'pageSize': 5
    };

    var response = await http.post(url, headers: headers, body: jsonEncode(body));

    return response;
  }
}

class LatLng {
  late double latitude;
  late double longitude;

  LatLng({ required this.latitude, required this.longitude });

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
    return PlacePrediction(
        id: json['id'],
        name: json['displayName']['text'],
        address: json['formattedAddress']
    );
  }

  Map<String, String> toJson() => {
    'id': id,
    'name': name,
    'address': address,
  };
}
