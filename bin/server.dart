import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart' hide Route;

import 'utils/places.dart';
import 'utils/routes.dart';

void main(List<String> args) async {
  final app = Router();
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(app.call);

  app.get('/api', (Request request) {
    return Response(HttpStatus.ok, body: "SERVER ONLINE");
  });

  app.post('/api/places', (Request request) async {
    final data = jsonDecode(await request.readAsString());

    final query = data['query'];

    final location = data['location'];

    // Cast possible integers to double
    final lat = location['lat'] + 0.0;
    final long = location['long'] + 0.0;

    var coordinates = LatLng(latitude: lat, longitude: long);

    var response = await Places.getAutocomplete(query, coordinates);

    var body = jsonDecode(response.body);

    var places = body['places'];

    if (places == null) {
      return Response(HttpStatus.ok, body: jsonEncode([]));
    }

    var searchResults = <PlacePrediction>[];

    for (var place in places) {
      searchResults.add(PlacePrediction.fromJson(place));
    }

    return Response(HttpStatus.ok, body: jsonEncode(searchResults));
  });

  app.post('/api/routes', (Request request) async {
    final data = jsonDecode(await request.readAsString());

    final originAddress = data['origin'];
    final destinationAddress = data['dest'];

    var response = await Routes.getRoutes(originAddress, destinationAddress);

    var body = jsonDecode(response.body);

    var routes = body['routes'];

    var routeResults = <Route>[];

    for (var route in routes) {
      routeResults.add(await Route.fromJson(route));
    }

    return Response(HttpStatus.ok, body: jsonEncode(routeResults));
  });

  final server = await serve(handler, '0.0.0.0', port);

  print('Server listening on port ${server.port}');
}