import 'package:dev_test/package.dart';
import 'package:path/path.dart';
import 'package:tekartik_build_utils/android/android_import.dart';

var topDir = '..';

Future main() async {
  if (dartVersion >= Version(2, 12, 0, pre: '0')) {
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
}
