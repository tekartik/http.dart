import 'package:tekartik_http_io/http_server_io.dart';
import 'package:tekartik_http_redirect/http_redirect.dart';

Future main() async {
  await startServer(
      httpServerFactoryIo,
      Options()
        ..handleCors = true
        ..forwardHeaders = false);
}
