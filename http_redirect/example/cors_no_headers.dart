import 'package:tekartik_http_io/http_io.dart';
// ignore: deprecated_member_use_from_same_package
import 'package:tekartik_http_redirect/http_redirect.dart';

Future<void> main() async {
  await HttpRedirectServer.startServer(
    httpFactory: httpFactoryIo,
    options: Options()
      ..handleCors = true
      ..forwardHeaders = false,
  );
}
