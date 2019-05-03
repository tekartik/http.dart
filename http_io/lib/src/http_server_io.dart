import 'dart:async';
import 'dart:io' as io;

import 'package:tekartik_http/http_server.dart';

class HttpHeadersIo implements HttpHeaders {
  final io.HttpHeaders ioHttpHeaders;
  @override
  ContentType get contentType =>
      ContentType.parse(ioHttpHeaders.contentType.toString());

  HttpHeadersIo(this.ioHttpHeaders);

  @override
  List<String> operator [](String name) => ioHttpHeaders[name];

  @override
  void add(String name, Object value) => ioHttpHeaders.add(name, value);

  @override
  void forEach(void Function(String name, List<String> values) f) =>
      ioHttpHeaders.forEach(f);

  @override
  void set(String name, Object value) => ioHttpHeaders.set(name, value);

  @override
  String value(String name) => ioHttpHeaders.value(name);

  @override
  set contentType(ContentType contentType) =>
      ioHttpHeaders.contentType = io.ContentType.parse(contentType.toString());
}

class HttpResponseIo extends Sink<List<int>> implements HttpResponse {
  final io.HttpResponse ioHttpResponse;

  HttpResponseIo(this.ioHttpResponse);

  @override
  int get contentLength => ioHttpResponse.contentLength;

  @override
  set contentLength(int contentLength) =>
      ioHttpResponse.contentLength = contentLength;

  @override
  int get statusCode => ioHttpResponse.statusCode;
  @override
  set statusCode(int statusCode) => ioHttpResponse.statusCode = statusCode;

  @override
  void add(List<int> data) => ioHttpResponse.add(data);

  @override
  void addError(Object error, [StackTrace stackTrace]) =>
      ioHttpResponse.addError(error, stackTrace);

  @override
  Future addStream(Stream<List<int>> stream) =>
      ioHttpResponse.addStream(stream);

  @override
  Future close() => ioHttpResponse.close();

  @override
  Future get done => ioHttpResponse.done;

  @override
  Future flush() => ioHttpResponse.flush();

  @override
  HttpHeaders get headers => HttpHeadersIo(ioHttpResponse.headers);

  @override
  void write(Object obj) => ioHttpResponse.write(obj);
}

class HttpRequestIo extends Stream<List<int>> implements HttpRequest {
  final io.HttpRequest ioHttpRequest;

  HttpRequestIo(this.ioHttpRequest);

  @override
  int get contentLength => ioHttpRequest.contentLength;

  @override
  HttpHeaders get headers => null;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event) onData,
      {Function onError, void Function() onDone, bool cancelOnError}) {
    return ioHttpRequest.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  String get method => ioHttpRequest.method;

  @override
  Uri get requestedUri => ioHttpRequest.requestedUri;

  @override
  HttpResponse get response => HttpResponseIo(ioHttpRequest.response);

  @override
  Uri get uri => ioHttpRequest.uri;
}

class HttpServerIo extends Stream<HttpRequest> implements HttpServer {
  final io.HttpServer ioHttpServer;

  HttpServerIo(this.ioHttpServer);
  @override
  Future close({bool force = false}) => ioHttpServer.close(force: force);

  @override
  StreamSubscription<HttpRequest> listen(
      void Function(HttpRequest event) onData,
      {Function onError,
      void Function() onDone,
      bool cancelOnError}) {
    return ioHttpServer.transform<HttpRequest>(
        StreamTransformer<io.HttpRequest, HttpRequest>.fromHandlers(
            handleData: (request, sink) {
      sink.add(HttpRequestIo(request));
    })).listen(onData,
        onDone: onDone, onError: onError, cancelOnError: cancelOnError);
  }

  @override
  int get port => ioHttpServer.port;
}

class IoHttpServerFactory implements HttpServerFactory {
  @override
  Future<HttpServer> bind(address, int port) async {
    var ioHttpServer = await io.HttpServer.bind(address, port);
    if (ioHttpServer != null) {
      return HttpServerIo(ioHttpServer);
    }
    return null;
  }
}

IoHttpServerFactory _ioHttpServerFactory;
IoHttpServerFactory get httpServerFactoryIo =>
    _ioHttpServerFactory ??= IoHttpServerFactory();
