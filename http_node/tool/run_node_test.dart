import 'dart:async';

import 'package:tekartik_build_utils/cmd_run.dart';

Future main() async {
  // pub run build_runner test --fail-on-severe -- -p chrome -r expanded
  await runCmd(PubCmd(['run', 'test', '-p', 'node', '-r', 'expanded']),
      verbose: true);
}
