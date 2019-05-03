import 'dart:io';

import 'package:process_run/shell.dart';
import 'package:tekartik_common_utils/version_utils.dart';

Version parsePlatformVersion(String text) {
  return Version.parse(text.split(' ').first);
}

Future main() async {
  var shell = Shell();

  await shell.run('''
dartanalyzer --fatal-warnings --fatal-infos .
# pub run build_runner test -- -p vm
# pub run build_runner test -- -p chrome
pub run test -p vm,chrome
''');

  // Fails on Dart 2.1.1
  var dartVersion = parsePlatformVersion(Platform.version);
  if (dartVersion >= Version(2, 2, 0, pre: 'dev')) {
    await shell.run('''
    pub run build_runner test -- -p chrome,firefox
  ''');
  }
}
