import 'package:process_run/shell.dart';

Future main() async {
  var shell = Shell();

  await shell.run('''

pub run build_runner test -- -p chrome,firefox -r expanded

''');
}
