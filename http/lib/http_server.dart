import 'package:tekartik_http/src/http_server.dart';
import 'package:tekartik_http/src/http_server_memory.dart' as memory;

export 'dart:io' show HttpResponse, HttpRequest, HttpServer, ContentType;

export 'package:tekartik_http/src/http_server.dart'
    show HttpServerFactory, httpServerGetUri;

HttpServerFactory get httpServerFactoryMemory => memory.httpServerFactoryMemory;
