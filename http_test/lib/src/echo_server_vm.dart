import 'dart:async';

import 'package:stream_channel/stream_channel.dart';
import 'package:tekartik_http/http.dart';
import 'package:tekartik_http_io/http_server_io.dart';
import 'package:tekartik_http_test/test_server.dart';

/// Starts the redirect test HTTP server in the same process.
Future<StreamChannel<Object?>> startServer() async {
  final controller = StreamChannelController<Object?>(sync: true);
  hybridMain(controller.foreign);
  return controller.local;
}

/// Starts an HTTP server that captures the content type header and request
/// body.
///
/// Channel protocol:
///    On Startup:
///     - send port
///    On Request Received:
///     - send "Content-Type" header
///     - send request body
///    When Receive Anything:
///     - exit
void hybridMain(StreamChannel<Object?> channel) async {
  var server = await httpServerFactoryIo.bind(localhost, 0);
  server.listen(handleEchoRequest);
  channel.sink.add(server.port);
  await channel
      .stream.first; // Any writes indicates that the server should exit.
  unawaited(server.close());
}
