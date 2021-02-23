import 'dart:async';
import 'dart:typed_data';

import 'package:tekartik_http/http.dart';

import 'http_server_mixin.dart';

class _InternetAddressType implements InternetAddressType {
  @override
  String toString() {
    if (this == InternetAddressType.IPv4) {
      return 'IPv4';
    } else if (this == InternetAddressType.IPv6) {
      return 'IPv6';
    }
    return super.toString();
  }
}

class _InternetAddress implements InternetAddress {
  @override
  final InternetAddressType type;

  @override
  final String? address;

  _InternetAddress(this.type, this.address);

  @override
  String toString() {
    if (this == InternetAddress.anyIPv4) {
      return 'anyIPv4/0.0.0.0';
      //} else if (this == InternetAddress.anyIPv6) {
      //  return 'anyIPv6';
    }
    return '$address $type';
  }
}

/// [InternetAddressType] is the type an [InternetAddress]. Currently,
/// IP version 4 (IPv4) and IP version 6 (IPv6) are supported.
class InternetAddressType {
  /// IPv4 address type.
  // ignore: non_constant_identifier_names
  static final InternetAddressType IPv4 = _InternetAddressType();

  /// IPv6 address type.
  // ignore: non_constant_identifier_names
  static final InternetAddressType IPv6 = _InternetAddressType();
}

/// An internet address.
///
/// This object holds an internet address. If this internet address
/// is the result of a DNS lookup, the address also holds the hostname
/// used to make the lookup.
/// An Internet address combined with a port number represents an
/// endpoint to which a socket can connect or a listening socket can
/// bind.
abstract class InternetAddress {
  /// Tekartik extension;
  static InternetAddress get any => anyIPv4;
  /*
  /// IP version 4 loopback address. Use this address when listening on
  /// or connecting to the loopback adapter using IP version 4 (IPv4).
  static InternetAddress get loopbackIPv4 => LOOPBACK_IP_V4;
  @Deprecated("Use loopbackIPv4 instead")
  external static InternetAddress get LOOPBACK_IP_V4;

  /// IP version 6 loopback address. Use this address when listening on
  /// or connecting to the loopback adapter using IP version 6 (IPv6).
  static InternetAddress get loopbackIPv6 => LOOPBACK_IP_V6;
  @Deprecated("Use loopbackIPv6 instead")
  external static InternetAddress get LOOPBACK_IP_V6;
  */
  /// IP version 4 any address. Use this address when listening on
  /// all adapters IP addresses using IP version 4 (IPv4).
  static final anyIPv4 = _InternetAddress(InternetAddressType.IPv4, null);
  /*
  @Deprecated("Use anyIPv4 instead")
  external static InternetAddress get ANY_IP_V4;

  /// IP version 6 any address. Use this address when listening on
  /// all adapters IP addresses using IP version 6 (IPv6).
  static InternetAddress get anyIPv6 => ANY_IP_V6;
  @Deprecated("Use anyIPv6 instead")
  external static InternetAddress get ANY_IP_V6;
  */
  /// The [type] of the [InternetAddress] specified what IP protocol.
  InternetAddressType get type;

  /// The numeric address of the host. For IPv4 addresses this is using
  /// the dotted-decimal notation. For IPv6 it is using the
  /// hexadecimal representation.
  String? get address;

  /*
  /// The host used to lookup the address. If there is no host
  /// associated with the address this returns the numeric address.
  String get host;

  /// Get the raw address of this [InternetAddress]. The result is either a
  /// 4 or 16 byte long list. The returned list is a copy, making it possible
  /// to change the list without modifying the [InternetAddress].
  List<int> get rawAddress;

  /// Returns true if the [InternetAddress] is a loopback address.
  bool get isLoopback;

  /// Returns true if the [InternetAddress]s scope is a link-local.
  bool get isLinkLocal;

  /// Returns true if the [InternetAddress]s scope is multicast.
  bool get isMulticast;

  /// Creates a new [InternetAddress] from a numeric address.
  ///
  /// If the address in [address] is not a numeric IPv4
  /// (dotted-decimal notation) or IPv6 (hexadecimal representation).
  /// address [ArgumentError] is thrown.
  external factory InternetAddress(String address);

  /// Perform a reverse dns lookup on the [address], creating a new
  /// [InternetAddress] where the host field set to the result.
  Future<InternetAddress> reverse();

  /// Lookup a host, returning a Future of a list of
  /// [InternetAddress]s. If [type] is [InternetAddressType.ANY], it
  /// will lookup both IP version 4 (IPv4) and IP version 6 (IPv6)
  /// addresses. If [type] is either [InternetAddressType.IPv4] or
  /// [InternetAddressType.IPv6] it will only lookup addresses of the
  /// specified type. The order of the list can, and most likely will,
  /// change over time.
  external static Future<List<InternetAddress>> lookup(String host,
      {InternetAddressType type = InternetAddressType.any});

  /// Clones the given [address] with the new [host].
  ///
  /// The [address] must be an [InternetAddress] that was created with one
  /// of the static methods of this class.
  external static InternetAddress _cloneWithNewHost(
      InternetAddress address, String host);
      */
}

/// A server-side object
/// that contains the content of and information about an HTTP request.
///
/// __Note__: Check out the
/// [http_server](https://pub.dartlang.org/packages/http_server)
/// package, which makes working with the low-level
/// dart:io HTTP server subsystem easier.
///
/// `HttpRequest` objects are generated by an [HttpServer],
/// which listens for HTTP requests on a specific host and port.
/// For each request received, the HttpServer, which is a [Stream],
/// generates an `HttpRequest` object and adds it to the stream.
///
/// An `HttpRequest` object delivers the body content of the request
/// as a stream of byte lists.
/// The object also contains information about the request,
/// such as the method, URI, and headers.
///
/// In the following code, an HttpServer listens
/// for HTTP requests. When the server receives a request,
/// it uses the HttpRequest object's `method` property to dispatch requests.
///
///     final HOST = InternetAddress.loopbackIPv4;
///     final PORT = 80;
///
///     HttpServer.bind(HOST, PORT).then((_server) {
///       _server.listen((HttpRequest request) {
///         switch (request.method) {
///           case 'GET':
///             handleGetRequest(request);
///             break;
///           case 'POST':
///             ...
///         }
///       },
///       onError: handleError);    // listen() failed.
///     }).catchError(handleError);
///
/// An HttpRequest object provides access to the associated [HttpResponse]
/// object through the response property.
/// The server writes its response to the body of the HttpResponse object.
/// For example, here's a function that responds to a request:
///
///     void handleGetRequest(HttpRequest req) {
///       HttpResponse res = req.response;
///       res.write('Received request ${req.method}: ${req.uri.path}');
///       res.close();
///     }
abstract class HttpRequest implements Stream<Uint8List> {
  /// The content length of the request body.
  ///
  /// If the size of the request body is not known in advance,
  /// this value is -1.
  int? get contentLength;

  /// The method, such as 'GET' or 'POST', for the request.
  String get method;

  /// The URI for the request.
  ///
  /// This provides access to the
  /// path and query string for the request.
  Uri get uri;

  /// The requested URI for the request.
  ///
  /// The returned URI is reconstructed by using http-header fields, to access
  /// otherwise lost information, e.g. host and scheme.
  ///
  /// To reconstruct the scheme, first 'X-Forwarded-Proto' is checked, and then
  /// falling back to server type.
  ///
  /// To reconstruct the host, first 'X-Forwarded-Host' is checked, then 'Host'
  /// and finally calling back to server.
  Uri get requestedUri;

  /// The request headers.
  ///
  /// The returned [HttpHeaders] are immutable.
  HttpHeaders get headers;

  /*
  /// The cookies in the request, from the Cookie headers.
  List<Cookie> get cookies;

  /// The persistent connection state signaled by the client.
  bool get persistentConnection;

  /// The client certificate of the client making the request.
  ///
  /// This value is null if the connection is not a secure TLS or SSL connection,
  /// or if the server does not request a client certificate, or if the client
  /// does not provide one.
  X509Certificate get certificate;

  /// The session for the given request.
  ///
  /// If the session is
  /// being initialized by this call, [:isNew:] is true for the returned
  /// session.
  /// See [HttpServer.sessionTimeout] on how to change default timeout.
  HttpSession get session;

  /// The HTTP protocol version used in the request,
  /// either "1.0" or "1.1".
  String get protocolVersion;

  /// Information about the client connection.
  ///
  /// Returns [:null:] if the socket is not available.
  HttpConnectionInfo get connectionInfo;
  */
  /// The [HttpResponse] object, used for sending back the response to the
  /// client.
  ///
  /// If the [contentLength] of the body isn't 0, and the body isn't being read,
  /// any write calls on the [HttpResponse] automatically drain the request
  /// body.
  HttpResponse get response;
}

/// An HTTP response, which returns the headers and data
/// from the server to the client in response to an HTTP request.
///
/// Every HttpRequest object provides access to the associated [HttpResponse]
/// object through the `response` property.
/// The server sends its response to the client by writing to the
/// HttpResponse object.
///
/// ## Writing the response
///
/// This class implements [IOSink].
/// After the header has been set up, the methods
/// from IOSink, such as `writeln()`, can be used to write
/// the body of the HTTP response.
/// Use the `close()` method to close the response and send it to the client.
///
///     server.listen((HttpRequest request) {
///       request.response.write('Hello, world!');
///       request.response.close();
///     });
///
/// When one of the IOSink methods is used for the
/// first time, the request header is sent. Calling any methods that
/// change the header after it is sent throws an exception.
///
/// ## Setting the headers
///
/// The HttpResponse object has a number of properties for setting up
/// the HTTP headers of the response.
/// When writing string data through the IOSink, the encoding used
/// is determined from the "charset" parameter of the
/// "Content-Type" header.
///
///     HttpResponse response = ...
///     response.headers.contentType
///         = new ContentType("application", "json", charset: "utf-8");
///     response.write(...);  // Strings written will be UTF-8 encoded.
///
/// If no charset is provided the default of ISO-8859-1 (Latin 1) will
/// be used.
///
///     HttpResponse response = ...
///     response.headers.add(HttpHeaders.contentTypeHeader, "text/plain");
///     response.write(...);  // Strings written will be ISO-8859-1 encoded.
///
/// An exception is thrown if you use the `write()` method
/// while an unsupported content-type is set.
abstract class HttpResponse implements StreamSink<Uint8List>, StringSink {
  // TODO(ajohnsen): Add documentation of how to pipe a file to the response.
  /// Gets and sets the content length of the response. If the size of
  /// the response is not known in advance set the content length to
  /// -1, which is also the default if not set.
  int? contentLength;

  /// Gets and sets the status code. Any integer value is accepted. For
  /// the official HTTP status codes use the fields from
  /// [HttpStatus]. If no status code is explicitly set the default
  /// value [HttpStatus.ok] is used.
  ///
  /// The status code must be set before the body is written
  /// to. Setting the status code after writing to the response body or
  /// closing the response will throw a `StateError`.
  late int statusCode;

  /*
  /// Gets and sets the reason phrase. If no reason phrase is explicitly
  /// set a default reason phrase is provided.
  ///
  /// The reason phrase must be set before the body is written
  /// to. Setting the reason phrase after writing to the response body
  /// or closing the response will throw a `StateError`.
  String reasonPhrase;

  /// Gets and sets the persistent connection state. The initial value
  /// of this property is the persistent connection state from the
  /// request.
  bool persistentConnection;

  /// Set and get the [deadline] for the response. The deadline is timed from the
  /// time it's set. Setting a new deadline will override any previous deadline.
  /// When a deadline is exceeded, the response will be closed and any further
  /// data ignored.
  ///
  /// To disable a deadline, set the [deadline] to `null`.
  ///
  /// The [deadline] is `null` by default.
  Duration deadline;

  /// Gets or sets if the [HttpResponse] should buffer output.
  ///
  /// Default value is `true`.
  ///
  /// __Note__: Disabling buffering of the output can result in very poor
  /// performance, when writing many small chunks.
  bool bufferOutput;
  */
  /// Returns the response headers.
  ///
  /// The response headers can be modified until the response body is
  /// written to or closed. After that they become immutable.
  HttpHeaders get headers;

  /*
  /// Cookies to set in the client (in the 'set-cookie' header).
  List<Cookie> get cookies;
  */
  /// Respond with a redirect to [location].
  ///
  /// The URI in [location] should be absolute, but there are no checks
  /// to enforce that.
  ///
  /// By default the HTTP status code `HttpStatus.movedTemporarily`
  /// (`302`) is used for the redirect, but an alternative one can be
  /// specified using the [status] argument.
  ///
  /// This method will also call `close`, and the returned future is
  /// the future returned by `close`.
  Future redirect(Uri location, {int status = httpStatusMovedTemporarily});
  /*

  /// Detaches the underlying socket from the HTTP server. When the
  /// socket is detached the HTTP server will no longer perform any
  /// operations on it.
  ///
  /// This is normally used when a HTTP upgrade request is received
  /// and the communication should continue with a different protocol.
  ///
  /// If [writeHeaders] is `true`, the status line and [headers] will be written
  /// to the socket before it's detached. If `false`, the socket is detached
  /// immediately, without any data written to the socket. Default is `true`.
  Future<Socket> detachSocket({bool writeHeaders = true});

  /// Gets information about the client connection. Returns [:null:] if the
  /// socket is not available.
  HttpConnectionInfo get connectionInfo;
  */

  /// Returns a [Future] that completes once all buffered data is accepted by the
  /// underlying [StreamConsumer].
  ///
  /// This method must not be called while an [addStream] is incomplete.
  ///
  /// NOTE: This is not necessarily the same as the data being flushed by the
  /// operating system.
  Future flush();

  /// Converts [obj] to a String by invoking [Object.toString] and
  /// [add]s the encoding of the result to the target consumer.
  ///
  /// This operation is non-blocking. See [flush] or [done] for how to get any
  /// errors generated by this call.
  @override
  void write(Object? obj);
}

/// A server that delivers content, such as web pages, using the HTTP protocol.
///
/// The HttpServer is a [Stream] that provides [HttpRequest] objects. Each
/// HttpRequest has an associated [HttpResponse] object.
/// The server responds to a request by writing to that HttpResponse object.
/// The following example shows how to bind an HttpServer to an IPv6
/// [InternetAddress] on port 80 (the standard port for HTTP servers)
/// and how to listen for requests.
/// Port 80 is the default HTTP port. However, on most systems accessing
/// this requires super-user privileges. For local testing consider
/// using a non-reserved port (1024 and above).
///
///     import 'dart:io';
///
///     main() {
///       HttpServer
///           .bind(InternetAddress.anyIPv6, 80)
///           .then((server) {
///             server.listen((HttpRequest request) {
///               request.response.write('Hello, world!');
///               request.response.close();
///             });
///           });
///     }
///
/// Incomplete requests, in which all or part of the header is missing, are
/// ignored, and no exceptions or HttpRequest objects are generated for them.
/// Likewise, when writing to an HttpResponse, any [Socket] exceptions are
/// ignored and any future writes are ignored.
///
/// The HttpRequest exposes the request headers and provides the request body,
/// if it exists, as a Stream of data. If the body is unread, it is drained
/// when the server writes to the HttpResponse or closes it.
///
/// ## Bind with a secure HTTPS connection
///
/// Use [bindSecure] to create an HTTPS server.
///
/// The server presents a certificate to the client. The certificate
/// chain and the private key are set in the [SecurityContext]
/// object that is passed to [bindSecure].
///
///     import 'dart:io';
///     import "dart:isolate";
///
///     main() {
///       SecurityContext context = new SecurityContext();
///       var chain =
///           Platform.script.resolve('certificates/server_chain.pem')
///           .toFilePath();
///       var key =
///           Platform.script.resolve('certificates/server_key.pem')
///           .toFilePath();
///       context.useCertificateChain(chain);
///       context.usePrivateKey(key, password: 'dartdart');
///
///       HttpServer
///           .bindSecure(InternetAddress.anyIPv6,
///                       443,
///                       context)
///           .then((server) {
///             server.listen((HttpRequest request) {
///               request.response.write('Hello, world!');
///               request.response.close();
///             });
///           });
///     }
///
///  The certificates and keys are PEM files, which can be created and
///  managed with the tools in OpenSSL.
///
/// ## Connect to a server socket
///
/// You can use the [listenOn] constructor to attach an HTTP server to
/// a [ServerSocket].
///
///     import 'dart:io';
///
///     main() {
///       ServerSocket.bind(InternetAddress.anyIPv6, 80)
///         .then((serverSocket) {
///           HttpServer httpserver = new HttpServer.listenOn(serverSocket);
///           serverSocket.listen((Socket socket) {
///             socket.write('Hello, client.');
///           });
///         });
///     }
///
/// ## Other resources
///
/// * HttpServer is a Stream. Refer to the [Stream] class for information
/// about the streaming qualities of an HttpServer.
/// Pausing the subscription of the stream, pauses at the OS level.
///
/// * The [shelf](https://pub.dartlang.org/packages/shelf)
/// package on pub.dartlang.org contains a set of high-level classes that,
/// together with this class, makes it easy to provide content through HTTP
/// servers.
abstract class HttpServer implements Stream<HttpRequest> {
  /*
  /// Gets and sets the default value of the `Server` header for all responses
  /// generated by this [HttpServer].
  ///
  /// If [serverHeader] is `null`, no `Server` header will be added to each
  /// response.
  ///
  /// The default value is `null`.
  String serverHeader;

  /// Default set of headers added to all response objects.
  ///
  /// By default the following headers are in this set:
  ///
  ///     Content-Type: text/plain; charset=utf-8
  ///     X-Frame-Options: SAMEORIGIN
  ///     X-Content-Type-Options: nosniff
  ///     X-XSS-Protection: 1; mode=block
  ///
  /// If the `Server` header is added here and the `serverHeader` is set as
  /// well then the value of `serverHeader` takes precedence.
  HttpHeaders get defaultResponseHeaders;

  /// Whether the [HttpServer] should compress the content, if possible.
  ///
  /// The content can only be compressed when the response is using
  /// chunked Transfer-Encoding and the incoming request has `gzip`
  /// as an accepted encoding in the Accept-Encoding header.
  ///
  /// The default value is `false` (compression disabled).
  /// To enable, set `autoCompress` to `true`.
  bool autoCompress;

  /// Gets or sets the timeout used for idle keep-alive connections. If no
  /// further request is seen within [idleTimeout] after the previous request was
  /// completed, the connection is dropped.
  ///
  /// Default is 120 seconds.
  ///
  /// Note that it may take up to `2 * idleTimeout` before a idle connection is
  /// aborted.
  ///
  /// To disable, set [idleTimeout] to `null`.
  Duration idleTimeout;

  /// Starts listening for HTTP requests on the specified [address] and
  /// [port].
  ///
  /// The [address] can either be a [String] or an
  /// [InternetAddress]. If [address] is a [String], [bind] will
  /// perform a [InternetAddress.lookup] and use the first value in the
  /// list. To listen on the loopback adapter, which will allow only
  /// incoming connections from the local host, use the value
  /// [InternetAddress.loopbackIPv4] or
  /// [InternetAddress.loopbackIPv6]. To allow for incoming
  /// connection from the network use either one of the values
  /// [InternetAddress.anyIPv4] or [InternetAddress.anyIPv6] to
  /// bind to all interfaces or the IP address of a specific interface.
  ///
  /// If an IP version 6 (IPv6) address is used, both IP version 6
  /// (IPv6) and version 4 (IPv4) connections will be accepted. To
  /// restrict this to version 6 (IPv6) only, use [v6Only] to set
  /// version 6 only. However, if the address is
  /// [InternetAddress.loopbackIPv6], only IP version 6 (IPv6) connections
  /// will be accepted.
  ///
  /// If [port] has the value [:0:] an ephemeral port will be chosen by
  /// the system. The actual port used can be retrieved using the
  /// [port] getter.
  ///
  /// The optional argument [backlog] can be used to specify the listen
  /// backlog for the underlying OS listen setup. If [backlog] has the
  /// value of [:0:] (the default) a reasonable value will be chosen by
  /// the system.
  ///
  /// The optional argument [shared] specifies whether additional HttpServer
  /// objects can bind to the same combination of `address`, `port` and `v6Only`.
  /// If `shared` is `true` and more `HttpServer`s from this isolate or other
  /// isolates are bound to the port, then the incoming connections will be
  /// distributed among all the bound `HttpServer`s. Connections can be
  /// distributed over multiple isolates this way.
  static Future<HttpServer> bind(address, int port,
          {int backlog = 0, bool v6Only = false, bool shared = false}) =>
      _HttpServer.bind(address, port, backlog, v6Only, shared);

  /// The [address] can either be a [String] or an
  /// [InternetAddress]. If [address] is a [String], [bind] will
  /// perform a [InternetAddress.lookup] and use the first value in the
  /// list. To listen on the loopback adapter, which will allow only
  /// incoming connections from the local host, use the value
  /// [InternetAddress.loopbackIPv4] or
  /// [InternetAddress.loopbackIPv6]. To allow for incoming
  /// connection from the network use either one of the values
  /// [InternetAddress.anyIPv4] or [InternetAddress.anyIPv6] to
  /// bind to all interfaces or the IP address of a specific interface.
  ///
  /// If an IP version 6 (IPv6) address is used, both IP version 6
  /// (IPv6) and version 4 (IPv4) connections will be accepted. To
  /// restrict this to version 6 (IPv6) only, use [v6Only] to set
  /// version 6 only.
  ///
  /// If [port] has the value [:0:] an ephemeral port will be chosen by
  /// the system. The actual port used can be retrieved using the
  /// [port] getter.
  ///
  /// The optional argument [backlog] can be used to specify the listen
  /// backlog for the underlying OS listen setup. If [backlog] has the
  /// value of [:0:] (the default) a reasonable value will be chosen by
  /// the system.
  ///
  /// If [requestClientCertificate] is true, the server will
  /// request clients to authenticate with a client certificate.
  /// The server will advertise the names of trusted issuers of client
  /// certificates, getting them from a [SecurityContext], where they have been
  /// set using [SecurityContext.setClientAuthorities].
  ///
  /// The optional argument [shared] specifies whether additional HttpServer
  /// objects can bind to the same combination of `address`, `port` and `v6Only`.
  /// If `shared` is `true` and more `HttpServer`s from this isolate or other
  /// isolates are bound to the port, then the incoming connections will be
  /// distributed among all the bound `HttpServer`s. Connections can be
  /// distributed over multiple isolates this way.

  static Future<HttpServer> bindSecure(
          address, int port, SecurityContext context,
          {int backlog = 0,
          bool v6Only = false,
          bool requestClientCertificate = false,
          bool shared = false}) =>
      _HttpServer.bindSecure(address, port, context, backlog, v6Only,
          requestClientCertificate, shared);

  /// Attaches the HTTP server to an existing [ServerSocket]. When the
  /// [HttpServer] is closed, the [HttpServer] will just detach itself,
  /// closing current connections but not closing [serverSocket].
  factory HttpServer.listenOn(ServerSocket serverSocket) =>
      _HttpServer.listenOn(serverSocket);
  */
  /// Permanently stops this [HttpServer] from listening for new
  /// connections.  This closes the [Stream] of [HttpRequest]s with a
  /// done event. The returned future completes when the server is
  /// stopped. For a server started using [bind] or [bindSecure] this
  /// means that the port listened on no longer in use.
  ///
  /// If [force] is `true`, active connections will be closed immediately.
  Future close({bool force = false});

  /// Returns the port that the server is listening on. This can be
  /// used to get the actual port used when a value of 0 for [:port:] is
  /// specified in the [bind] or [bindSecure] call.
  int get port;

  /// Returns the address that the server is listening on. This can be
  /// used to get the actual address used, when the address is fetched by
  /// a lookup from a hostname.
  InternetAddress? get address;

  /*
  /// Sets the timeout, in seconds, for sessions of this [HttpServer].
  /// The default timeout is 20 minutes.
  set sessionTimeout(int timeout);

  /// Returns an [HttpConnectionsInfo] object summarizing the number of
  /// current connections handled by the server.
  HttpConnectionsInfo connectionsInfo();
  */
}

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

/// Representation of a content type. An instance of [ContentType] is
/// immutable.
abstract class ContentType
// implements HeaderValue
{
  /*
  /// Content type for plain text using UTF-8 encoding.
  ///
  ///     text/plain; charset=utf-8
  static final text = ContentType("text", "plain", charset: "utf-8");
  @Deprecated("Use text instead")
  static final TEXT = text;

  ///  Content type for HTML using UTF-8 encoding.
  ///
  ///     text/html; charset=utf-8
  static final html = ContentType("text", "html", charset: "utf-8");
  @Deprecated("Use html instead")
  static final HTML = html;

  ///  Content type for JSON using UTF-8 encoding.
  ///
  ///     application/json; charset=utf-8
  static final json = ContentType("application", "json", charset: "utf-8");
  @Deprecated("Use json instead")
  static final JSON = json;

  ///  Content type for binary data.
  ///
  ///     application/octet-stream
  static final binary = ContentType("application", "octet-stream");
  @Deprecated("Use binary instead")
  static final BINARY = binary;

  /// Creates a new content type object setting the primary type and
  /// sub type. The charset and additional parameters can also be set
  /// using [charset] and [parameters]. If charset is passed and
  /// [parameters] contains charset as well the passed [charset] will
  /// override the value in parameters. Keys passed in parameters will be
  /// converted to lower case. The `charset` entry, whether passed as `charset`
  /// or in `parameters`, will have its value converted to lower-case.
  factory ContentType(String primaryType, String subType,
      {String charset, Map<String, String> parameters}) {
    return _ContentType(primaryType, subType, charset, parameters);
  }
  */
  /// Creates a new content type object from parsing a Content-Type
  /// header value. As primary type, sub type and parameter names and
  /// values are not case sensitive all these values will be converted
  /// to lower case. Parsing this string
  ///
  ///     text/html; charset=utf-8
  ///
  /// will create a content type object with primary type [:text:], sub
  /// type [:html:] and parameter [:charset:] with value [:utf-8:].
  static ContentType parse(String value) {
    // return _ContentType.parse(value);
    return ContentTypeImpl(value);
  }
  /*

  /// Gets the mime-type, without any parameters.
  String get mimeType;

  /// Gets the primary type.
  String get primaryType;

  /// Gets the sub type.
  String get subType;

  /// Gets the character set.
  String get charset;
  */
}

/// Content type implementation.
class ContentTypeImpl implements ContentType {
  final String _value;

  /// Wrap a content type on a string value.
  ContentTypeImpl(this._value);

  @override
  String toString() => _value;
}

/// Http server factory.
abstract class HttpServerFactory {
  /// Creates a http server on given address and port
  /// Use 0 to automatically assign a port
  Future<HttpServer> bind(dynamic address, int port);
}

/// not exported
Uri httpServerGetDefaultUri(HttpServer server) =>
    Uri.parse('http://${localhost}:${server.port}/');

/// Node does not support root uri. / appendend on puropose
Uri httpServerGetUri(HttpServer server) {
  if (server is HttpServerWithUri) {
    return (server as HttpServerWithUri).uri;
  }

  return httpServerGetDefaultUri(server);
}
