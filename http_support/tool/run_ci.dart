import 'package:dev_test/package.dart';
import 'package:path/path.dart';

var topDir = '..';

Future main() async {
  for (var dir in [
    'http',
    'http_browser',
    'http_io',
    // 'http_node',
    'http_test',
    'http_redirect',
  ]) {
    await packageRunCi(join(topDir, dir));
  }
}
