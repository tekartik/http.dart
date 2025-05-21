import 'dart:async';
import 'dart:convert';
//import 'dart:io';

import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:tekartik_http/http.dart';
import 'package:tekartik_http/src/http_server_memory.dart';
import 'package:tekartik_http/src/http_server_mixin.dart';
import 'package:tekartik_http/src/utils.dart';

/// Http map headers.
class HttpHeadersMemory with HttpHeadersMixin implements HttpHeaders {
  /// Internal map
  final _map = <String, List<String>>{};

  /// Keys
  Iterable<String> get keys => _map.keys;

  @override
  List<String>? operator [](String name) => _map[_getKey(name)];

  /// Length
  int get length => _map.length;

  /// Convert key
  String _getKey(String name) => name.toLowerCase();

  @override
  void add(String name, Object value) {
    var key = _getKey(name);
    var list = _map[key];
    if (list == null) {
      list = [value.toString()];
      _map[key] = list;
    } else {
      list.add(value.toString());
    }
  }

  @override
  void forEach(void Function(String name, List<String> values) f) =>
      _map.forEach(f);

  @override
  void set(String name, Object value) {
    var key = _getKey(name);
    if (value is List) {
      _map[key] = value.cast<String>();
    } else {
      _map[key] = [value.toString()];
    }
  }

  /// Add a map
  void addMap(Map<String, String> map) {
    map.forEach((key, value) {
      add(key, value);
    });
  }

  @override
  String? value(String name) => _map[_getKey(name)]?.first.toString();

  @override
  set contentType(ContentType? contentType) =>
      set(httpHeaderContentType, contentType.toString());

  @override
  ContentType? get contentType {
    var contentTypeValue = value(httpHeaderContentType);
    if (contentTypeValue != null) {
      return ContentType.parse(contentTypeValue);
    }
    return null;
  }

  /// Clear
  void clear() {
    _map.clear();
  }

  /// Remove a key
  List<String>? remove(String key) {
    return _map.remove(_getKey(key));
  }
}

/// Http client request.
class HttpRequestMemory extends Stream<Uint8List> implements HttpRequest {
  @override
  final Uri uri;

  /// Port
  final int port;

  /// Body
  final Object? body;

  /// Encoding
  final Encoding? encoding;
  @override
  int? contentLength;

  /// Create a new http request.
  HttpRequestMemory(
    this.method,
    Uri uri, {
    Map<String, String>? headers,
    this.body,
    this.encoding,
  }) : port = parseUri(uri).port,
       // Remove the fragment that should not reach the server
       uri = uri.removeFragment() {
    headers?.forEach((key, value) {
      this.headers.set(key, value);
    });
    if (body is String) {
      var bytes = getBodyAsBytes(body, encoding: encoding);
      contentLength = bytes.length;
      _streamCtlr.add(bytes);
    } else if (body is Uint8List) {
      var bytes = body as Uint8List;
      contentLength = bytes.length;
      _streamCtlr.add(bytes);
    } else if (body is List<int>) {
      var bytes = body as List<int>;
      contentLength = bytes.length;
      _streamCtlr.add(Uint8List.fromList(bytes));
    } else {
      contentLength = 0;
    }
    _streamCtlr.close();
  }

  @override
  StreamSubscription<Uint8List> listen(
    void Function(Uint8List event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _streamCtlr.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  final HttpHeaders headers = HttpHeadersMemory();

  @override
  final String method;

  /// Stream controller
  final _streamCtlr = StreamController<Uint8List>();

  /*
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
  */
  // TODO: implement requestedUri
  @override
  Uri get requestedUri => throw 'not implemented yet';

  HttpResponseMemory? _response;

  @override
  HttpResponseMemory get response =>
      _response ??= HttpResponseMemory(Request(method, uri));

  /*
  // TODO: implement session
  @override
  HttpSession get session => throw 'not implemented yet';
  */

  /// Close the request
  Future<void> close() async {}
}

/// Http response in memory.
class HttpResponseMemory implements StreamSink<Uint8List>, HttpResponse {
  final Request _request;
  final _streamCtlr = StreamController<Uint8List>();
  final _responseCompleter = Completer<ResponseMemory>();

  /// Create a new http response.
  HttpResponseMemory(this._request);

  /// Future response
  Future<Response> get response => _responseCompleter.future;

  /*
  @override
  bool bufferOutput;
  */
  @override
  late int contentLength;

  /*
  @override
  Duration deadline;

  @override
  Encoding encoding;

  @override
  bool persistentConnection;

  @override
  String reasonPhrase;
  */
  @override
  int get statusCode => _statusCode!;

  int? _statusCode;

  @override
  final HttpHeaders headers = HttpHeadersMemory();

  @override
  void add(Uint8List data) {
    _streamCtlr.add(data);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _streamCtlr.addError(error, stackTrace);
  }

  @override
  Future addStream(Stream<Uint8List> stream) => _streamCtlr.addStream(stream);

  @override
  Future close() async {
    // Default status code
    _statusCode ??= httpStatusCodeOk;
    var futureBytes = _streamCtlr.stream.toList();
    await _streamCtlr.close();
    var data = <int>[];
    var bytesLists = await futureBytes;
    for (var list in bytesLists) {
      data.addAll(list);
    }
    _responseCompleter.complete(
      ResponseMemory(_request, this, Uint8List.fromList(data)),
    );
  }

  /*
  // TODO: implement connectionInfo
  @override
  HttpConnectionInfo get connectionInfo => throw 'not implemented yet';

  // TODO: implement cookies
  @override
  List<Cookie> get cookies => throw 'not implemented yet';

  @override
  Future<Socket> detachSocket({bool writeHeaders = true}) =>
      throw 'not implemented yet';

  // TODO: implement done
  */
  @override
  Future get done => _streamCtlr.done;

  @override
  Future<void> flush() async {
    // No action
  }

  @override
  Future redirect(Uri location, {int status = httpStatusMovedTemporarily}) =>
      throw 'not implemented yet';

  @override
  void write(Object? obj) {
    if (obj is String) {
      add(asUint8List(utf8.encode(obj)));
    } else {
      // Only type supported
      add(asUint8List(obj as List<int>));
    }
  }

  @override
  void writeAll(Iterable objects, [String separator = '']) {
    write(objects.join(separator));
  }

  @override
  void writeCharCode(int charCode) {
    write(String.fromCharCode(charCode));
  }

  @override
  void writeln([Object? obj = '']) {
    write('$obj\n');
  }

  @override
  set statusCode(int statusCode) {
    _statusCode = statusCode;
  }

  /*
  @override
  void writeAll(Iterable objects, [String separator = '']) =>
      throw 'not implemented yet';

  @override
  void writeCharCode(int charCode) => throw 'not implemented yet';

  @override
  void writeln([Object obj = '']) => throw 'not implemented yet';
  */
}

/// Http response in memory.
class ResponseMemory implements Response {
  final Request _request;
  final HttpResponseMemory _httpResponseMemory;

  /// Create a new http response.
  ResponseMemory(this._request, this._httpResponseMemory, this.bodyBytes) {
    _httpResponseMemory.headers.forEach((name, values) {
      if (values.length > 1) {
        headers[name] = values.join();
      } else {
        headers[name] = values.first;
      }
    });
  }

  @override
  String get body => utf8.decode(bodyBytes);

  @override
  final Uint8List bodyBytes;

  @override
  int get contentLength => bodyBytes.length;

  @override
  final headers = {};

  // TODO: implement isRedirect
  @override
  bool get isRedirect => throw 'not implemented yet';

  // TODO: implement persistentConnection
  @override
  bool get persistentConnection => throw 'not implemented yet';

  // TODO: implement reasonPhrase
  @override
  String get reasonPhrase => throw 'not implemented yet';

  // TODO: implement statusCode
  @override
  int get statusCode => _httpResponseMemory.statusCode;

  @override
  BaseRequest get request => _request;
}

/// Http client mixin.
mixin HttpClientMixin implements Client {
  /// httpCall
  Future<Response> httpCall(
    String method,
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  });

  /// httpSend
  Future<StreamedResponse> httpSend(
    String method,
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  });

  @override
  Future<Uint8List> readBytes(url, {Map<String, String>? headers}) async {
    var response = await this.get(url, headers: headers);
    return response.bodyBytes;
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    dynamic body;
    var data = <int>[];
    await request.finalize().listen((part) {
      data.addAll(part);
    }).asFuture<void>();
    body = data;

    return httpSend(
      request.method,
      request.url,
      headers: request.headers,
      body: body,
    );
  }
}

/// Http client in memory.
class HttpClientMemory extends BaseClient
    with HttpClientMixin
    implements Client {
  @override
  void close() {
    // TODO: implement close
  }

  @override
  Future<Response> httpCall(
    String method,
    Uri url, {
    Map<String, String>? headers,
    body,
    Encoding? encoding,
  }) async {
    var request = HttpRequestMemory(
      method,
      parseUri(url),
      headers: headers,
      body: body,
      encoding: encoding,
    );
    var server = httpDataMemory.servers[request.port];
    if (server == null) {
      throw Exception('no server found for url $url port ${request.port}');
    }
    //request.add(getBodyAsBytes(getBodyAsBytes(body, encoding: encoding)));
    //request.close();
    server.addRequest(request);

    // wait for response
    var response = await request.response.response;
    return response;
  }

  @override
  Future<StreamedResponse> httpSend(
    String method,
    Uri url, {
    Map<String, String>? headers,
    body,
    Encoding? encoding,
  }) async {
    var response = await httpCall(
      method,
      url,
      headers: headers,
      body: body,
      encoding: encoding,
    );
    return StreamedResponse(
      () async* {
        yield response.bodyBytes;
      }(),
      response.statusCode,
      contentLength: response.contentLength,
      headers: response.headers,
      request: response.request,
    );
  }
}

/// Http client factory in memory.
class HttpClientFactoryMemory extends HttpClientFactory {
  @override
  Client newClient() {
    var client = HttpClientMemory();
    return client;
  }
}

HttpClientFactoryMemory? _httpClientFactoryMemory;

/// Http client factory in memory.
HttpClientFactoryMemory get httpClientFactoryMemory =>
    _httpClientFactoryMemory ??= HttpClientFactoryMemory();
