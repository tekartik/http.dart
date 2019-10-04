import 'package:tekartik_http/src/http_server.dart';
import 'package:tekartik_http/src/http_server_memory.dart' as memory;

// export 'dart:io' show HttpResponse, HttpRequest, HttpServer, ContentType;

export 'package:tekartik_http/src/http_server.dart'
    show
        HttpServerFactory,
        httpServerGetUri,
        HttpServer,
        HttpRequest,
        HttpResponse,
        InternetAddress,
        InternetAddressType,
        HttpHeaders,
        ContentType;

/// deprecated.
@deprecated
HttpServerFactory get httpServerFactoryMemory => memory.httpServerFactoryMemory;
