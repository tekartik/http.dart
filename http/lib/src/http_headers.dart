import 'package:tekartik_http/http.dart';

/// Headers for HTTP requests and responses.
///
/// In some situations, headers are immutable:
///
/// * HttpRequest and HttpClientResponse always have immutable headers.
///
/// * HttpResponse and HttpClientRequest have immutable headers
///   from the moment the body is written to.
///
/// In these situations, the mutating methods throw exceptions.
///
/// For all operations on HTTP headers the header name is
/// case-insensitive.
///
/// To set the value of a header use the `set()` method:
///
///     request.headers.set(HttpHeaders.cacheControlHeader,
///                         'max-age=3600, must-revalidate');
///
/// To retrieve the value of a header use the `value()` method:
///
///     print(request.headers.value(HttpHeaders.userAgentHeader));
///
/// An HttpHeaders object holds a list of values for each name
/// as the standard allows. In most cases a name holds only a single value,
/// The most common mode of operation is to use `set()` for setting a value,
/// and `value()` for retrieving a value.
abstract class HttpHeaders {
  /*
  static const acceptHeader = "accept";
  static const acceptCharsetHeader = "accept-charset";
  static const acceptEncodingHeader = "accept-encoding";
  static const acceptLanguageHeader = "accept-language";
  static const acceptRangesHeader = "accept-ranges";
  static const ageHeader = "age";
  static const allowHeader = "allow";
  static const authorizationHeader = "authorization";
  static const cacheControlHeader = "cache-control";
  static const connectionHeader = "connection";
  static const contentEncodingHeader = "content-encoding";
  static const contentLanguageHeader = "content-language";
  static const contentLengthHeader = "content-length";
  static const contentLocationHeader = "content-location";
  static const contentMD5Header = "content-md5";
  static const contentRangeHeader = "content-range";
  static const contentTypeHeader = "content-type";
  static const dateHeader = "date";
  static const etagHeader = "etag";
  static const expectHeader = "expect";
  static const expiresHeader = "expires";
  static const fromHeader = "from";
  static const hostHeader = "host";
  static const ifMatchHeader = "if-match";
  static const ifModifiedSinceHeader = "if-modified-since";
  static const ifNoneMatchHeader = "if-none-match";
  static const ifRangeHeader = "if-range";
  static const ifUnmodifiedSinceHeader = "if-unmodified-since";
  static const lastModifiedHeader = "last-modified";
  static const locationHeader = "location";
  static const maxForwardsHeader = "max-forwards";
  static const pragmaHeader = "pragma";
  static const proxyAuthenticateHeader = "proxy-authenticate";
  static const proxyAuthorizationHeader = "proxy-authorization";
  static const rangeHeader = "range";
  static const refererHeader = "referer";
  static const retryAfterHeader = "retry-after";
  static const serverHeader = "server";
  static const teHeader = "te";
  static const trailerHeader = "trailer";
  static const transferEncodingHeader = "transfer-encoding";
  static const upgradeHeader = "upgrade";
  static const userAgentHeader = "user-agent";
  static const varyHeader = "vary";
  static const viaHeader = "via";
  static const warningHeader = "warning";
  static const wwwAuthenticateHeader = "www-authenticate";

  @Deprecated("Use acceptHeader instead")
  static const ACCEPT = acceptHeader;
  @Deprecated("Use acceptCharsetHeader instead")
  static const ACCEPT_CHARSET = acceptCharsetHeader;
  @Deprecated("Use acceptEncodingHeader instead")
  static const ACCEPT_ENCODING = acceptEncodingHeader;
  @Deprecated("Use acceptLanguageHeader instead")
  static const ACCEPT_LANGUAGE = acceptLanguageHeader;
  @Deprecated("Use acceptRangesHeader instead")
  static const ACCEPT_RANGES = acceptRangesHeader;
  @Deprecated("Use ageHeader instead")
  static const AGE = ageHeader;
  @Deprecated("Use allowHeader instead")
  static const ALLOW = allowHeader;
  @Deprecated("Use authorizationHeader instead")
  static const AUTHORIZATION = authorizationHeader;
  @Deprecated("Use cacheControlHeader instead")
  static const CACHE_CONTROL = cacheControlHeader;
  @Deprecated("Use connectionHeader instead")
  static const CONNECTION = connectionHeader;
  @Deprecated("Use contentEncodingHeader instead")
  static const CONTENT_ENCODING = contentEncodingHeader;
  @Deprecated("Use contentLanguageHeader instead")
  static const CONTENT_LANGUAGE = contentLanguageHeader;
  @Deprecated("Use contentLengthHeader instead")
  static const CONTENT_LENGTH = contentLengthHeader;
  @Deprecated("Use contentLocationHeader instead")
  static const CONTENT_LOCATION = contentLocationHeader;
  @Deprecated("Use contentMD5Header instead")
  static const CONTENT_MD5 = contentMD5Header;
  @Deprecated("Use contentRangeHeader instead")
  static const CONTENT_RANGE = contentRangeHeader;
  @Deprecated("Use contentTypeHeader instead")
  static const CONTENT_TYPE = contentTypeHeader;
  @Deprecated("Use dateHeader instead")
  static const DATE = dateHeader;
  @Deprecated("Use etagHeader instead")
  static const ETAG = etagHeader;
  @Deprecated("Use expectHeader instead")
  static const EXPECT = expectHeader;
  @Deprecated("Use expiresHeader instead")
  static const EXPIRES = expiresHeader;
  @Deprecated("Use fromHeader instead")
  static const FROM = fromHeader;
  @Deprecated("Use hostHeader instead")
  static const HOST = hostHeader;
  @Deprecated("Use ifMatchHeader instead")
  static const IF_MATCH = ifMatchHeader;
  @Deprecated("Use ifModifiedSinceHeader instead")
  static const IF_MODIFIED_SINCE = ifModifiedSinceHeader;
  @Deprecated("Use ifNoneMatchHeader instead")
  static const IF_NONE_MATCH = ifNoneMatchHeader;
  @Deprecated("Use ifRangeHeader instead")
  static const IF_RANGE = ifRangeHeader;
  @Deprecated("Use ifUnmodifiedSinceHeader instead")
  static const IF_UNMODIFIED_SINCE = ifUnmodifiedSinceHeader;
  @Deprecated("Use lastModifiedHeader instead")
  static const LAST_MODIFIED = lastModifiedHeader;
  @Deprecated("Use locationHeader instead")
  static const LOCATION = locationHeader;
  @Deprecated("Use maxForwardsHeader instead")
  static const MAX_FORWARDS = maxForwardsHeader;
  @Deprecated("Use pragmaHeader instead")
  static const PRAGMA = pragmaHeader;
  @Deprecated("Use proxyAuthenticateHeader instead")
  static const PROXY_AUTHENTICATE = proxyAuthenticateHeader;
  @Deprecated("Use proxyAuthorizationHeader instead")
  static const PROXY_AUTHORIZATION = proxyAuthorizationHeader;
  @Deprecated("Use rangeHeader instead")
  static const RANGE = rangeHeader;
  @Deprecated("Use refererHeader instead")
  static const REFERER = refererHeader;
  @Deprecated("Use retryAfterHeader instead")
  static const RETRY_AFTER = retryAfterHeader;
  @Deprecated("Use serverHeader instead")
  static const SERVER = serverHeader;
  @Deprecated("Use teHeader instead")
  static const TE = teHeader;
  @Deprecated("Use trailerHeader instead")
  static const TRAILER = trailerHeader;
  @Deprecated("Use transferEncodingHeader instead")
  static const TRANSFER_ENCODING = transferEncodingHeader;
  @Deprecated("Use upgradeHeader instead")
  static const UPGRADE = upgradeHeader;
  @Deprecated("Use userAgentHeader instead")
  static const USER_AGENT = userAgentHeader;
  @Deprecated("Use varyHeader instead")
  static const VARY = varyHeader;
  @Deprecated("Use viaHeader instead")
  static const VIA = viaHeader;
  @Deprecated("Use warningHeader instead")
  static const WARNING = warningHeader;
  @Deprecated("Use wwwAuthenticateHeader instead")
  static const WWW_AUTHENTICATE = wwwAuthenticateHeader;

  // Cookie headers from RFC 6265.
  static const cookieHeader = "cookie";
  static const setCookieHeader = "set-cookie";

  @Deprecated("Use cookieHeader instead")
  static const COOKIE = cookieHeader;
  @Deprecated("Use setCookieHeader instead")
  static const SET_COOKIE = setCookieHeader;

  static const generalHeaders = [
    cacheControlHeader,
    connectionHeader,
    dateHeader,
    pragmaHeader,
    trailerHeader,
    transferEncodingHeader,
    upgradeHeader,
    viaHeader,
    warningHeader
  ];

  @Deprecated("Use generalHeaders instead")
  static const GENERAL_HEADERS = generalHeaders;

  static const entityHeaders = [
    allowHeader,
    contentEncodingHeader,
    contentLanguageHeader,
    contentLengthHeader,
    contentLocationHeader,
    contentMD5Header,
    contentRangeHeader,
    contentTypeHeader,
    expiresHeader,
    lastModifiedHeader
  ];

  @Deprecated("Use entityHeaders instead")
  static const ENTITY_HEADERS = entityHeaders;

  static const responseHeaders = [
    acceptRangesHeader,
    ageHeader,
    etagHeader,
    locationHeader,
    proxyAuthenticateHeader,
    retryAfterHeader,
    serverHeader,
    varyHeader,
    wwwAuthenticateHeader
  ];

  @Deprecated("Use responseHeaders instead")
  static const RESPONSE_HEADERS = responseHeaders;

  static const requestHeaders = [
    acceptHeader,
    acceptCharsetHeader,
    acceptEncodingHeader,
    acceptLanguageHeader,
    authorizationHeader,
    expectHeader,
    fromHeader,
    hostHeader,
    ifMatchHeader,
    ifModifiedSinceHeader,
    ifNoneMatchHeader,
    ifRangeHeader,
    ifUnmodifiedSinceHeader,
    maxForwardsHeader,
    proxyAuthorizationHeader,
    rangeHeader,
    refererHeader,
    teHeader,
    userAgentHeader
  ];

  @Deprecated("Use requestHeaders instead")
  static const REQUEST_HEADERS = requestHeaders;

  /// Gets and sets the date. The value of this property will
  /// reflect the 'date' header.
  DateTime date;

  /// Gets and sets the expiry date. The value of this property will
  /// reflect the 'expires' header.
  DateTime expires;

  /// Gets and sets the "if-modified-since" date. The value of this property will
  /// reflect the "if-modified-since" header.
  DateTime ifModifiedSince;

  /// Gets and sets the host part of the 'host' header for the
  /// connection.
  String host;

  /// Gets and sets the port part of the 'host' header for the
  /// connection.
  int port;
  */

  /// Gets and sets the content type. Note that the content type in the
  /// header will only be updated if this field is set
  /// directly. Mutating the returned current value will have no
  /// effect.
  ContentType? contentType;

  /*

  /// Gets and sets the content length header value.
  int contentLength;

  /// Gets and sets the persistent connection header value.
  bool persistentConnection;

  /// Gets and sets the chunked transfer encoding header value.
  bool chunkedTransferEncoding;
  */

  /// Returns the list of values for the header named [name]. If there
  /// is no header with the provided name, [:null:] will be returned.
  List<String>? operator [](String name);

  /// Convenience method for the value for a single valued header. If
  /// there is no header with the provided name, [:null:] will be
  /// returned. If the header has more than one value an exception is
  /// thrown.
  String? value(String name);

  /// Adds a header value. The header named [name] will have the value
  /// [value] added to its list of values. Some headers are single
  /// valued, and for these adding a value will replace the previous
  /// value. If the value is of type DateTime a HTTP date format will be
  /// applied. If the value is a [:List:] each element of the list will
  /// be added separately. For all other types the default [:toString:]
  /// method will be used.
  void add(String name, Object value);

  /// Sets a header. The header named [name] will have all its values
  /// cleared before the value [value] is added as its value.
  void set(String name, Object value);

  /*
  /// Removes a specific value for a header name. Some headers have
  /// system supplied values and for these the system supplied values
  /// will still be added to the collection of values for the header.
  void remove(String name, Object value);

  /// Removes all values for the specified header name. Some headers
  /// have system supplied values and for these the system supplied
  /// values will still be added to the collection of values for the
  /// header.
  void removeAll(String name);
  */

  /// Enumerates the headers, applying the function [f] to each
  /// header. The header name passed in [:name:] will be all lower
  /// case.
  void forEach(void Function(String name, List<String> values) f);
/*

  /// Disables folding for the header named [name] when sending the HTTP
  /// header. By default, multiple header values are folded into a
  /// single header line by separating the values with commas. The
  /// 'set-cookie' header has folding disabled by default.
  void noFolding(String name);

  /// Remove all headers. Some headers have system supplied values and
  /// for these the system supplied values will still be added to the
  /// collection of values for the header.
  void clear();
  */
}

/// Convenience methods for headers.
extension HttpHeadersExt on HttpHeaders {
  /// Convert to a map where the value is either a single value or a list of values
  Map<String, /* String | List<String> */ Object?> toMap() {
    var map = <String, Object?>{};
    forEach((name, values) {
      if (values.length == 1) {
        map[name] = values.single;
      } else {
        map[name] = values;
      }
      map[name] = values;
    });
    return map;
  }
}
