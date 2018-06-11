import 'dart:async';

import 'dart:convert';
import 'dart:io';

import 'dart:typed_data';

import 'package:http/src/base_request.dart';
import 'package:http/src/client.dart';
import 'package:http/src/response.dart';
import 'package:http/src/streamed_response.dart';
import 'package:tekartik_http/http.dart';
import 'package:tekartik_http/src/http.dart';
import 'package:tekartik_http/src/http_server_memory.dart';

class HttpHeadersMemory implements HttpHeaders {
  final Map<String, List<String>> map = {};
  @override
  bool chunkedTransferEncoding;

  @override
  int contentLength;

  @override
  DateTime date;

  @override
  DateTime expires;

  @override
  String host;

  @override
  DateTime ifModifiedSince;

  @override
  bool persistentConnection;

  @override
  int port;

  @override
  List<String> operator [](String name) => map[getKey(name)];

  String getKey(String name) => name.toLowerCase();
  @override
  void add(String name, Object value) {
    var key = getKey(name);
    var list = map[key];
    if (list == null) {
      list = [value?.toString()];
      map[key] = list;
    } else {
      list.add(value?.toString());
    }
  }

  @override
  void clear() {
    map.clear();
  }

  @override
  void forEach(void Function(String name, List<String> values) f) =>
      map.forEach(f);

  @override
  void noFolding(String name) => throw 'not implemented yet';

  @override
  void remove(String name, Object value) {
    var key = getKey(name);
    var list = map[key];
    if (list != null) {
      list.remove(value?.toString());
      if (list == null) {
        map.remove(key);
      }
    }
  }

  @override
  void removeAll(String name) {
    map.remove(getKey(name));
  }

  @override
  void set(String name, Object value) {
    var key = getKey(name);
    if (value is List) {
      map[key] = value.cast<String>();
    } else {
      map[key] = [value?.toString()];
    }
  }

  @override
  String value(String name) => map[getKey(name)]?.first?.toString();

  @override
  set contentType(ContentType contentType) =>
      set(httpHeaderContentType, contentType.toString());

  @override
  ContentType get contentType {
    var contentTypeValue = value(httpHeaderContentType);
    if (contentTypeValue != null) {
      return ContentType.parse(contentTypeValue);
    }
    return null;
  }
}

class HttpRequestMemory extends Stream<List<int>> implements HttpRequest {
  final int port;
  final body;
  final Encoding encoding;

  HttpRequestMemory(this.port, this.method,
      {Map<String, String> headers, this.body, this.encoding}) {
    headers?.forEach((key, value) {
      this.headers.set(key, value);
    });
    if (body is String) {
      streamCtlr.add(getBodyAsBytes(body, encoding: encoding));
    }
    streamCtlr.close();
  }

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event) onData,
      {Function onError, void Function() onDone, bool cancelOnError}) {
    return streamCtlr.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  final HttpHeaders headers = new HttpHeadersMemory();

  @override
  final String method;

  var streamCtlr = new StreamController<List<int>>();

  // TODO: implement certificate
  @override
  X509Certificate get certificate => throw 'not implemented yet';

  // TODO: implement connectionInfo
  @override
  HttpConnectionInfo get connectionInfo => throw 'not implemented yet';
  // TODO: implement contentLength
  @override
  int get contentLength => throw 'not implemented yet';

  // TODO: implement cookies
  @override
  List<Cookie> get cookies => throw 'not implemented yet';

  // TODO: implement persistentConnection
  @override
  bool get persistentConnection => throw 'not implemented yet';

  // TODO: implement protocolVersion
  @override
  String get protocolVersion => throw 'not implemented yet';

  // TODO: implement requestedUri
  @override
  Uri get requestedUri => throw 'not implemented yet';

  // TODO: implement response
  @override
  final HttpResponseMemory response = new HttpResponseMemory();

  // TODO: implement session
  @override
  HttpSession get session => throw 'not implemented yet';

  // TODO: implement uri
  @override
  Uri get uri => throw 'not implemented yet';

  Future close() => throw 'not implemented yet';
}

class HttpResponseMemory extends StreamSink<List<int>> implements HttpResponse {
  var streamCtlr = new StreamController<List<int>>();
  var responseCompleter = new Completer<ResponseMemory>();
  Future<ResponseMemory> get responseMemory => responseCompleter.future;
  @override
  bool bufferOutput;

  @override
  int contentLength;

  @override
  Duration deadline;

  @override
  Encoding encoding;

  @override
  bool persistentConnection;

  @override
  String reasonPhrase;

  @override
  int statusCode;

  @override
  final HttpHeaders headers = new HttpHeadersMemory();

  @override
  void add(List<int> data) {
    streamCtlr.add(data);
  }

  @override
  void addError(Object error, [StackTrace stackTrace]) {
    streamCtlr.addError(error, stackTrace);
  }

  @override
  Future addStream(Stream<List<int>> stream) => streamCtlr.addStream(stream);

  @override
  Future close() async {
    var futureBytes = streamCtlr.stream.toList();
    await streamCtlr.close();
    var data = <int>[];
    var bytesLists = await futureBytes;
    for (var list in bytesLists) {
      data.addAll(list);
    }
    responseCompleter
        .complete(new ResponseMemory(this, new Uint8List.fromList(data)));
  }

  // TODO: implement connectionInfo
  @override
  HttpConnectionInfo get connectionInfo => throw 'not implemented yet';

  // TODO: implement cookies
  @override
  List<Cookie> get cookies => throw 'not implemented yet';

  @override
  Future<Socket> detachSocket({bool writeHeaders: true}) =>
      throw 'not implemented yet';

  // TODO: implement done
  @override
  Future get done => streamCtlr.done;

  @override
  Future flush() => throw 'not implemented yet';

  @override
  Future redirect(Uri location, {int status: HttpStatus.MOVED_TEMPORARILY}) =>
      throw 'not implemented yet';

  @override
  void write(Object obj) {
    if (obj is String) {
      add(utf8.encode(obj));
    } else {
      add(obj as List<int>);
    }
  }

  @override
  void writeAll(Iterable objects, [String separator = ""]) =>
      throw 'not implemented yet';

  @override
  void writeCharCode(int charCode) => throw 'not implemented yet';

  @override
  void writeln([Object obj = ""]) => throw 'not implemented yet';
}

class ResponseMemory implements Response {
  final HttpResponseMemory httpResponseMemory;
  ResponseMemory(this.httpResponseMemory, this.bodyBytes) {
    httpResponseMemory.headers.forEach((name, values) {
      if (values.length > 1) {
        headers[name] = values.join();
      } else {
        headers[name] = values.first;
      }
    });
  }

  // TODO: implement body
  @override
  String get body => utf8.decode(bodyBytes);

  @override
  final Uint8List bodyBytes;

  // TODO: implement contentLength
  @override
  int get contentLength => bodyBytes.length;

  final Map<String, String> headers = {};

  // TODO: implement isRedirect
  @override
  bool get isRedirect => throw 'not implemented yet';

  // TODO: implement persistentConnection
  @override
  bool get persistentConnection => throw 'not implemented yet';

  // TODO: implement reasonPhrase
  @override
  String get reasonPhrase => throw 'not implemented yet';

  // TODO: implement request
  @override
  BaseRequest get request => throw 'not implemented yet';

  // TODO: implement statusCode
  @override
  int get statusCode => httpResponseMemory.statusCode;
}

class HttpClientMemory implements Client {
  @override
  void close() {
    // TODO: implement close
  }

  int getUrlPort(url) {
    Uri uri;
    if (url is Uri) {
      uri = url;
    } else {
      uri = Uri.parse(url.toString());
    }
    return uri.port ?? 80;
  }

  Future<ResponseMemory> _send(url, String method,
      {Map<String, String> headers, body, Encoding encoding}) async {
    var request = new HttpRequestMemory(getUrlPort(url), method,
        headers: headers, body: body, encoding: encoding);
    var server = httpDataMemory.servers[request.port];
    if (server == null) {
      throw new Exception(
          'no server found for url ${url} port ${request.port}');
    }
    //request.add(getBodyAsBytes(getBodyAsBytes(body, encoding: encoding)));
    //request.close();
    server.addRequest(request);

    // wait for response
    var response = await request.response.responseMemory;
    return response;
  }

  @override
  Future<Response> delete(url, {Map<String, String> headers}) =>
      _send(url, httpMethodDelete, headers: headers);

  @override
  Future<Response> get(url, {Map<String, String> headers}) =>
      _send(url, httpMethodGet, headers: headers);

  @override
  Future<Response> head(url, {Map<String, String> headers}) =>
      _send(url, httpMethodHead, headers: headers);

  @override
  Future<Response> patch(url,
          {Map<String, String> headers, body, Encoding encoding}) =>
      _send(url, httpMethodPatch,
          headers: headers, body: body, encoding: encoding);

  @override
  Future<Response> post(url,
          {Map<String, String> headers, body, Encoding encoding}) =>
      _send(url, httpMethodPost,
          headers: headers, body: body, encoding: encoding);

  @override
  Future<Response> put(url,
          {Map<String, String> headers, body, Encoding encoding}) =>
      _send(url, httpMethodPut,
          headers: headers, body: body, encoding: encoding);

  @override
  Future<String> read(url, {Map<String, String> headers}) async {
    var response = await get(url, headers: headers);
    return response.body;
  }

  @override
  Future<Uint8List> readBytes(url, {Map<String, String> headers}) async {
    var response = await get(url, headers: headers);
    return response.bodyBytes;
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    throw 'not supported yet';
  }
}

class HttpClientFactoryMemory extends HttpClientFactory {
  @override
  Client newClient() {
    var client = new HttpClientMemory();
    return client;
  }
}

HttpClientFactoryMemory _httpClientFactoryMemory;
HttpClientFactoryMemory get httpClientFactoryMemory =>
    _httpClientFactoryMemory ??= new HttpClientFactoryMemory();
