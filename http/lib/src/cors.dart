import 'package:tekartik_http/http.dart';

/// Handler for CORS (Cross-Origin Resource Sharing) headers in HTTP responses.
extension TekartikHttpRequestCorsExtension on HttpRequest {
  /// Handle CORS headers for the request.
  /// Returns `true` if the request method is `OPTIONS`, indicating a preflight request.
  ///
  /// Handle a CORS preflight request:
  /// https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#preflighted_requests
  bool handleCors() {
    response.headers
      ..add(
        httpAccessControlAllowMethods,
        '$httpMethodPost, $httpMethodOptions, $httpMethodGet, $httpMethodPatch, $httpMethodPut, $httpMethodDelete',
      )
      ..add(httpAccessControlAllowOrigin, '*')
      ..add(httpAccessControlAllowHeaders, '*')
      ..add(httpAccessControlExposeHeaders, '*');

    if (method == httpMethodOptions) {
      response.close();
      return true;
    }

    return false;
  }
}
