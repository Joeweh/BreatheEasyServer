import 'dart:convert';
import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import 'config.dart';
import 'utils/places.dart';

void main(List<String> args) async {
  Env.vars = DotEnv(includePlatformEnvironment: false)..load();

  final app = Router();
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(app.call);

  app.get('/api', (Request request) {
    return Response(HttpStatus.ok, body: "SERVER ONLINE");
  });

  app.post('/api/places', (Request request) async {
    final data = jsonDecode(await request.readAsString());

    final query = data['query'];
    final location = data['location'];

    var coordinates = LatLong(latitude: location['lat'], longitude: location['long']);

    var response = await Places.getAutocomplete(query, coordinates);

    var body = jsonDecode(response.body);

    var suggestions = body['suggestions'];

    var places = <PlacePrediction>[];

    for (var placePredictionMap in suggestions) {
      var placePrediction = PlacePrediction.fromJson(placePredictionMap);

      places.add(placePrediction);
    }

    return Response(HttpStatus.ok, body: jsonEncode(places));
  });

  final server = await serve(handler, '0.0.0.0', port);

  print('Server listening on port ${server.port}');
}