import 'package:process_run/shell.dart';

Future main() async {
  var shell = Shell();

  await shell.run('''
dartanalyzer --fatal-warnings --fatal-infos .
# pub run build_runner test -- -p chrome test/multiplatform
# pub run test -p vm,chrome,node
pub run test -p vm,node
''');
}
