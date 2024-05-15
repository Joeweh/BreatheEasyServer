import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

void main(List<String> args) async {
  final app = Router();
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(app.call);

  //app.mount("/api/users", UserAPI().router);

  app.get("/api", (Request request) {
    return Response(HttpStatus.ok, body: "SERVER ONLINE");
  });

  final server = await serve(handler, '0.0.0.0', port);

  print('Server listening on port ${server.port}');
}