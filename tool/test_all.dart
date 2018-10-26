//import 'package:tekartik_build_utils/cmd_run.dart';
import 'package:tekartik_build_utils/common_import.dart';

Future testHttp() async {
  var dir = 'http';
  await runCmd(pubCmd(pubGetArgs())..workingDirectory = dir);
  await runCmd(dartanalyzerCmd(['--fatal-warnings', 'lib', 'test'])
    ..workingDirectory = dir);
  await runCmd(pubCmd(pubRunTestArgs(platforms: ['vm', 'chrome']))
    ..workingDirectory = dir);
}

Future testHttpIo() async {
  var dir = 'http_io';
  await runCmd(pubCmd(pubGetArgs())..workingDirectory = dir);
  await runCmd(dartanalyzerCmd(['--fatal-warnings', 'lib', 'test'])
    ..workingDirectory = dir);
  await runCmd(
      pubCmd(pubRunTestArgs(platforms: ['vm']))..workingDirectory = dir);
}

Future testHttpBrowser() async {
  var dir = 'http_browser';
  await runCmd(pubCmd(pubGetArgs())..workingDirectory = dir);
  await runCmd(dartanalyzerCmd(['--fatal-warnings', 'lib', 'test'])
    ..workingDirectory = dir);
  /*
  await runCmd(
      pubCmd(pubRunTestArgs(platforms: ['chrome']))..workingDirectory = dir);
      */
}

Future testHttpNode() async {
  var dir = 'http_node';
  await runCmd(pubCmd(pubGetArgs())..workingDirectory = dir);
  await runCmd(dartanalyzerCmd(['--fatal-warnings', 'lib', 'test'])
    ..workingDirectory = dir);
  /*
  await runCmd(
      pubCmd(pubRunTestArgs(platforms: ['node']))..workingDirectory = dir);
      */
}

Future testHttpRedirect() async {
  var dir = 'http_redirect';
  await runCmd(flutterCmd(['packages', 'get'])..workingDirectory = dir);
  await runCmd(
      dartanalyzerCmd(['--fatal-warnings', 'lib'])..workingDirectory = dir);
  await runCmd(
      pubCmd(pubRunTestArgs(platforms: [/* not yet 'node' */ 'vm', 'chrome']))
        ..workingDirectory = dir);
}

Future testHttpTest() async {
  var dir = 'http_test';
  await runCmd(pubCmd(pubGetArgs())..workingDirectory = dir);
  await runCmd(
      dartanalyzerCmd(['--fatal-warnings', 'lib'])..workingDirectory = dir);
}

Future main() async {
  /*
  await testHttp();
  await testHttpBrowser();
  await testHttpIo();

  await testHttpNode();
  */
  await testHttpRedirect();
  await testHttpTest();
}
