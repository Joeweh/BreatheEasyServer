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
      'X-Goog-FieldMask': 'places.id,places.displayName,places.formattedAddress,places.location'
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

  factory LatLng.fromJson(Map<String, dynamic> json) {
    return LatLng(latitude: json['latitude'], longitude: json['longitude']);
  }

  Map<String, double> toJson() => {
    'lat': latitude,
    'long': longitude
  };
}

class PlacePrediction {
  late String name;
  late String address;
  late LatLng location;

  PlacePrediction({ required this.name, required this.address, required this.location });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    return PlacePrediction(
        name: json['displayName']['text'],
        address: json['formattedAddress'],
        location: LatLng.fromJson(json['location'])
    );
  }
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'address': address,
    'location': location
  };
}
