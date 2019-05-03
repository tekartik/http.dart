import 'package:process_run/shell.dart';

Future main() async {
  var shell = Shell();

  await shell.run('''

pub run test -p node test/http_node_test.dart -N 'request with library-level'

''');
}
