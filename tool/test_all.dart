//import 'package:tekartik_build_utils/cmd_run.dart';
import 'package:tekartik_build_utils/common_import.dart';

Future testHttp() async {
  var dir = 'http';
  await runCmd(PubCmd(pubGetArgs())..workingDirectory = dir);
  await runCmd(
      DartAnalyzerCmd(['--fatal-warnings', '--fatal-infos', 'lib', 'test'])
        ..workingDirectory = dir);
  await runCmd(PubCmd(pubRunTestArgs(platforms: ['vm', 'chrome']))
    ..workingDirectory = dir);
}

Future testHttpIo() async {
  var dir = 'http_io';
  await runCmd(PubCmd(pubGetArgs())..workingDirectory = dir);
  await runCmd(
      DartAnalyzerCmd(['--fatal-warnings', '--fatal-infos', 'lib', 'test'])
        ..workingDirectory = dir);
  await runCmd(
      PubCmd(pubRunTestArgs(platforms: ['vm']))..workingDirectory = dir);
}

Future testHttpBrowser() async {
  var dir = 'http_browser';
  await runCmd(PubCmd(pubGetArgs())..workingDirectory = dir);
  await runCmd(
      DartAnalyzerCmd(['--fatal-warnings', '--fatal-infos', 'lib', 'test'])
        ..workingDirectory = dir);
  /*
  await runCmd(
      PubCmd(pubRunTestArgs(platforms: ['chrome']))..workingDirectory = dir);
      */
}

Future testHttpNode() async {
  var dir = 'http_node';
  await runCmd(PubCmd(pubGetArgs())..workingDirectory = dir);
  await runCmd(
      DartAnalyzerCmd(['--fatal-warnings', '--fatal-infos', 'lib', 'test'])
        ..workingDirectory = dir);
  /*
  await runCmd(
      PubCmd(pubRunTestArgs(platforms: ['node']))..workingDirectory = dir);
      */
}

Future testHttpRedirect() async {
  var dir = 'http_redirect';
  await runCmd(FlutterCmd(['packages', 'get'])..workingDirectory = dir);
  await runCmd(DartAnalyzerCmd(['--fatal-warnings', '--fatal-infos', 'lib'])
    ..workingDirectory = dir);
  await runCmd(
      PubCmd(pubRunTestArgs(platforms: [/* not yet 'node' */ 'vm', 'chrome']))
        ..workingDirectory = dir);
}

Future testHttpTest() async {
  var dir = 'http_test';
  await runCmd(PubCmd(pubGetArgs())..workingDirectory = dir);
  await runCmd(DartAnalyzerCmd(['--fatal-warnings', '--fatal-infos', 'lib'])
    ..workingDirectory = dir);
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
