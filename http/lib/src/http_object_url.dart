import 'dart:typed_data';

import 'package:tekartik_http/src/http_client.dart';
import 'package:tekartik_http/src/http_constant.dart';

/// Object url (`blob:` url) support.
///
/// An object url references in-memory bytes. A client created by the same
/// factory can read it with a GET request (`client.readBytes(url)`,
/// `client.read(url)`, `httpClientSend(client, httpMethodGet, url)`), any
/// other method fails with a `ClientException`.
///
/// Implemented by the browser client factory (`URL.createObjectURL`) and the
/// memory client factory. Not supported on io. Check
/// [HttpClientFactoryObjectUrlExt.supportsObjectUrl] before using it.
abstract class HttpObjectUrlFactory {
  /// Creates a `blob:` url referencing a copy of [bytes].
  ///
  /// [contentType] is the mime type (e.g. `image/png` or
  /// `text/plain; charset=utf-8`) reported in the response
  /// `content-type` header when the url is read.
  ///
  /// The bytes stay referenced until [revokeObjectUrl] is called.
  Uri createObjectUrl(Uint8List bytes, {String? contentType});

  /// Releases the bytes referenced by a url created with [createObjectUrl].
  ///
  /// Reading the url afterwards fails with a `ClientException`.
  void revokeObjectUrl(Uri url);
}

/// Object url helpers on any [HttpClientFactory].
extension HttpClientFactoryObjectUrlExt on HttpClientFactory {
  /// True if this factory can create `blob:` urls readable by its clients.
  bool get supportsObjectUrl => this is HttpObjectUrlFactory;

  /// The object url factory.
  ///
  /// Throws an [UnsupportedError] if [supportsObjectUrl] is false.
  HttpObjectUrlFactory get objectUrlFactory {
    var self = this;
    if (self is HttpObjectUrlFactory) {
      return self as HttpObjectUrlFactory;
    }
    throw UnsupportedError(
      'Object url ($httpSchemeBlob:) not supported by $runtimeType',
    );
  }
}
