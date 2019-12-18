import 'package:process_run/shell.dart';

Future main() async {
  var shell = Shell();

  var dirs = 'example lib test tool';
  await shell.run('''
# Analyze code
dartanalyzer --fatal-warnings --fatal-infos $dirs
dartfmt -n --set-exit-if-changed $dirs

# Run tests
# pub run build_runner test -- -p vm,node
pub run test -p vm,node
''');
}
