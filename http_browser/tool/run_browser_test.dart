import 'dart:async';

import 'package:tekartik_build_utils/cmd_run.dart';

Future main() async {
  await runCmd(
      PbrCmd(
          ['test', '--fail-on-severe', '--', '-p', 'chrome', '-r', 'expanded']),
      verbose: true);
}
