import 'package:process_run/shell.dart';
import 'package:path/path.dart';

var topDir = '..';

Future main() async {
  var shell = Shell();

  for (var dir in [
    'http',
    'http_browser',
    'http_io',
    'http_node',
    'http_test',
    'http_redirect',
  ]) {
    shell = shell.pushd(join(topDir, dir));
    await shell.run('''
    
    pub get
    dart tool/travis.dart
    
''');
    shell = shell.popd();
  }
}
