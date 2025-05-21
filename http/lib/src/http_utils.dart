import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:tekartik_http/http.dart';

import 'utils.dart';

/// Base request common extension.
extension TekartikBaseRequestExtension on http.BaseRequest {
  http.Request get _request => this as http.Request;
  http.MultipartRequest get _multipartRequest => this as http.MultipartRequest;

  /// Copy the request.
  http.BaseRequest copyRequest({Uri? url}) {
    http.BaseRequest requestCopy;
    url ??= this.url;
    if (this is http.Request) {
      requestCopy =
          http.Request(method, url)
            ..encoding = _request.encoding
            ..bodyBytes = _request.bodyBytes;
    } else if (this is http.MultipartRequest) {
      requestCopy =
          http.MultipartRequest(method, url)
            ..fields.addAll(_multipartRequest.fields)
            ..files.addAll(_multipartRequest.files);
    } else if (this is http.StreamedRequest) {
      throw Exception('copying streamed requests is not supported');
    } else {
      throw Exception('request type is unknown, cannot copy');
    }

    requestCopy
      ..persistentConnection = persistentConnection
      ..followRedirects = followRedirects
      ..maxRedirects = maxRedirects
      ..headers.addAll(headers);

    return requestCopy;
  }
}

/// Stream response common extension.
extension TekartikStreamedResponseExtension on http.StreamedResponse {
  /// Copy an already read response.
  http.StreamedResponse copyWithBytes(Uint8List bytes) {
    return http.StreamedResponse(
      http.ByteStream.fromBytes(bytes),
      statusCode,
      contentLength: contentLength,
      headers: headers,
      request: request,
      isRedirect: isRedirect,
      persistentConnection: persistentConnection,
      reasonPhrase: reasonPhrase,
    );
  }
}

/// Common request extension.
extension TekartikTkHttpRequestExtension on HttpRequest {
  /// Get the body as a map.
  Future<Map<String, Object?>> get bodyAsMap async => (await bodyAsMapOrNull)!;

  /// Get the body as a map or null.
  Future<Map<String, Object?>?> get bodyAsMapOrNull async {
    return httpDataAsMapOrNull(await getBodyBytes());
  }
}

/// Common request extension.
extension TekartikHttpRequestExtension on http.Request {
  /// Get the body as a map.
  Map<String, Object?> get bodyAsMap => bodyAsMapOrNull!;

  /// Get the body as a map or null.
  Map<String, Object?>? get bodyAsMapOrNull {
    return httpDataAsMapOrNull(body);
  }
}

/// Common response extension.
extension TekartikHttpResponseExtension on http.Response {
  /// Get the body as a map.
  Map<String, Object?> get bodyAsMap => bodyAsMapOrNull!;

  /// Get the body as a map or null.
  Map<String, Object?>? get bodyAsMapOrNull {
    return httpDataAsMapOrNull(body);
  }

  /// Copy an already read response.
  http.Response copyWithBytes(Uint8List bytes) {
    return http.Response.bytes(
      bytes,
      statusCode,
      request: request,
      headers: headers,
      isRedirect: isRedirect,
      persistentConnection: persistentConnection,
      reasonPhrase: reasonPhrase,
    );
  }
}

/// Common response extension.
extension HttpClientResponseExtension on HttpClientResponse {
  /// Get the body as a map.
  Map<String, Object?> get bodyAsMap => bodyAsMapOrNull!;

  /// Get the body as a map or null.
  Map<String, Object?>? get bodyAsMapOrNull {
    return httpDataAsMapOrNull(body);
  }
}
