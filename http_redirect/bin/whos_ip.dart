import 'package:process_run/shell.dart';
import 'package:process_run/stdio.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';

Future<void> main() async {
  var result = await Shell(throwOnError: false).run('lsof -i :8180');

  var lines = result.outLines;
  for (var line in lines) {
    var out = line.split(' ').where((element) => element.isNotEmpty).toList();
    stdout.writeln(out);

    try {
      var pid = int.parse(out[1].toString());
      try {
        // devPrint(pid);
        await Shell().run('kill -9 $pid');
        return;
      } catch (e) {
        stderr.writeln(e);
      }
    } catch (_) {
      continue;
    }
  }
}
