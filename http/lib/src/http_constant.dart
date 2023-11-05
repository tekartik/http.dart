//
// Http methods
//

/// Http method GET.
const String httpMethodGet = 'GET';

/// Http method HEAD.
const String httpMethodHead = 'HEAD';

/// Http method POST.
const String httpMethodPost = 'POST';

/// Http method PUT.
const String httpMethodPut = 'PUT';

/// Http method DELETE.
const String httpMethodDelete = 'DELETE';

/// Http method PATCH.
const String httpMethodPatch = 'PATCH';

/// Http method PURGE.
const String httpMethodPurge = 'PURGE';

/// Http method OPTIONS.
const String httpMethodOptions = 'OPTIONS';

//
// Http headers
//

/// Http header Authorization.
const String httpHeaderAuthorization = 'Authorization';

/// Http header contentType.
const String httpHeaderContentType = 'Content-Type';

/// Http header Accept-Encoding (typically send by client).
const String httpHeaderAcceptEncoding = 'Accept-Encoding';

/// Http header Content-Encoding.
const String httpHeaderContentEncoding = 'Content-Encoding';

/// Http header userAgent.
const String httpHeaderUserAgent = 'User-Agent';

/// Http header accept.
const String httpHeaderAccept = 'Accept';

/// Http header Access-Control-Allow-Origin (CORS).
const String httpAccessControlAllowOrigin = 'Access-Control-Allow-Origin';

/// Http header Access-Control-Allow-Methods (CORS).
const String httpAccessControlAllowMethods = 'Access-Control-Allow-Methods';

/// Http content type json.
const String httpContentTypeJson = 'application/json';

/// Http content type utf8.
const String httpContentTypeCharsetUtf8 = 'charset=utf-8';

/// URL encoded
const httpContentTypeWwwFormUrlEncoded = 'application/x-www-form-urlencoded';

/// Http content type html.
const String httpContentTypeHtml = 'text/html';

/// Http content type text.
const String httpContentTypeText = 'text/plain';

/// Gzip
const String httpContentEncodingGzip = 'gzip';

/// Http port any.
const int httpPortAny = 0;

/// Http status code ok.
const int httpStatusCodeOk = 200;

/// Http status code moved temporarily.
const int httpStatusMovedTemporarily = 302;

/// Http status code bad request.
const int httpStatusCodeBadRequest = 400;

/// Http status code unauthorized.
const int httpStatusCodeUnauthorized = 401;

/// Http status code forbidden.
const int httpStatusCodeForbidden = 403;

/// Http status code not found.
const int httpStatusCodeNotFound = 404;

/// Http status code request timeout.
const int httpStatusCodeRequestTimeout = 408;

/// Http status code internal server error.
const int httpStatusCodeInternalServerError = 500;

/// Http status code service unavailable.
const int httpStatusCodeServiceUnavailable = 503;
