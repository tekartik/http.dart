import 'package:tekartik_http/http_server.dart';

mixin HttpHeadersMixin implements HttpHeaders {
  @override
  String toString() {
    var map = <String, dynamic>{};
    forEach((name, values) {
      map[name] = values;
    });
    return map.toString();
  }
}
