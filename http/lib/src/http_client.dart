import 'package:http/http.dart' as http;

abstract class HttpClientFactory {
  http.Client newClient();
}
