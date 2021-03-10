import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_http/http.dart';
import 'package:tekartik_http/http_client.dart' as http_client;

import 'http_client_memory.dart';

/// Http client factory.
abstract class HttpClientFactory {
  /// Create a new http client.
  http.Client newClient();
}

class _HttpClientResponseFromResponse extends HttpClientResponse {
  @override
  final Response response;

  _HttpClientResponseFromResponse(this.response) : super.impl();
}

abstract class HttpMapHeaders implements Map<String, String> {
  /// Get a single value
  String value(String key);
}

/// Read only
class HttpMapHeadersFromMap
    with MapMixin<String, String>
    implements HttpMapHeaders {
  final _map = HttpHeadersMemory();

  HttpMapHeadersFromMap(Map<String, String> map) {
    _map.addMap(map);
  }

  @override
  String operator [](Object key) => _map.value(key as String);

  @override
  void operator []=(String key, String value) => _map.set(key, value);

  @override
  String value(String key) => _map.value(key);

  @override
  void clear() {
    _map.clear();
  }

  @override
  Iterable<String> get keys => _map.keys;

  @override
  String remove(Object key) {
    var value = this.value(key as String);
    _map.map.remove(key);
    return value;
  }
}

/// Http client response.
abstract class HttpClientResponse {
  HttpClientResponse.impl();

  /// Create a client response from an http response.
  factory HttpClientResponse.fromResponse(Response response) {
    return _HttpClientResponseFromResponse(response);
  }

  /// Deprecated since 2020-10-20
  factory HttpClientResponse(Response response) {
    return _HttpClientResponseFromResponse(response);
  }

  /// True if succesful.
  bool get isSuccessful => statusCode < 400;

  Response get _response => response;

  /// Http response.
  Response get response;

  /// Http status code.
  int get statusCode => _response.statusCode;

  String _body;

  /// Body as a string.
  String get body => _body ??= _response.body;

  /// Body bytes.
  Uint8List get bodyBytes => _response.bodyBytes;

  /// Response headers.
  HttpMapHeaders get headers => HttpMapHeadersFromMap(_response.headers);

  /// Response reason phrase.
  String reasonPhrase;

  @override
  String toString() {
    var sb = StringBuffer();
    try {
      sb.write('HTTP $statusCode size ${bodyBytes.length} headers $headers');
    } catch (e) {
      sb.write(' error: $e');
    }
    return sb.toString();
  }
}

/// Http client exception.
class HttpClientException extends http.ClientException
    implements http_client.HttpClientException {
  @override
  final HttpClientResponse response;

  /// Creates an exception with a message and a response.
  HttpClientException({String message, @required this.response})
      : super(message, parseUri(response.response.request.url));

  @override
  int get statusCode => response.statusCode;
}

/// if [throwOnFailure] is true, throw on HttpClientException if not successful
Future<HttpClientResponse> httpClientSend(
    http.Client client, String method, Uri uri,
    {Map<String, String> headers,
    dynamic body,
    Encoding encoding,
    bool throwOnFailure}) async {
  //var uri = parseUri(url);

  var request = http.Request(method, uri);

  if (headers != null) request.headers.addAll(headers);
  if (encoding != null) request.encoding = encoding;
  if (body != null) {
    if (body is String) {
      request.body = body;
    } else if (body is List) {
      request.bodyBytes = body.cast<int>();
    } else if (body is Map) {
      request.bodyFields = body.cast<String, String>();
    } else {
      throw ArgumentError('Invalid request body "$body".');
    }
  }

  var response = await Response.fromStream(await client.send(request));
  var httpResponse = HttpClientResponse(response);

  if (throwOnFailure == true) {
    _checkResponseSuccess(httpResponse);
  }
  return httpResponse;
}

/// Throws a [HttpClientException] on Error
Future<String> httpClientRead(http.Client client, String method, Uri uri,
    {Map<String, String> headers, dynamic body, Encoding encoding}) async {
  var response = await httpClientSend(client, method, uri,
      headers: headers, body: body, encoding: encoding);
  if (_checkResponseSuccess(response)) {
    return response.body;
  } else {
    throw HttpClientException(response: response);
  }
}

/// Throws an error if [response] is not successful.
bool _checkResponseSuccess(HttpClientResponse response) {
  if (response.isSuccessful) {
    return true;
  }

  var message =
      'Request to ${response.response.request.url} failed with status ${response.statusCode}';
  if (response.reasonPhrase != null) {
    message = '$message: ${response.reasonPhrase}';
  }
  throw HttpClientException(message: message, response: response);
}
