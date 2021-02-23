import 'dart:async';

import 'package:tekartik_app_node_build/app_build.dart';

Future main() async {
  // pub run build_runner test --fail-on-severe -- -p chrome -r expanded
  await nodeRunTest();
  // await runCmd(PubCmd(['run', 'test', '-p', 'node', '-r', 'expanded']),      verbose: true);
}
