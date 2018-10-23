import 'package:grinder/grinder.dart';
import 'package:process_run/process_run.dart';
import 'package:tekartik_build_utils/bash/bash.dart';

String extraOptions = '';

main(List<String> args) {
  // Handle extra args after --
  // to specify test names
  for (int i = 0; i < args.length; i++) {
    if (args[i] == '--') {
      extraOptions = argumentsToString(args.sublist(i + 1));
      // remove the extra args
      args = args.sublist(0, i);
      break;
    }
  }
  grind(args);
}

@Task()
test_http_browser() async {
  await bash('''
set -xe
pushd http_browser
pub run test -p chrome -r expanded $extraOptions
pub run build_runner test --fail-on-severe -- -p chrome -r expanded $extraOptions
''', verbose: true);
}

@Task()
test_http_io() async {
  await bash('''
set -xe
pushd http_io
pub run test $extraOptions
pub run build_runner test
''', verbose: true);
}

@Task()
test_http_node() async {
  await bash('''
set -xe
pushd http_node
pub run test -p node $extraOptions
pub run build_runner test -- -p node
''', verbose: true);
}

@Task()
test_http_redirect() async {
  await bash('''
set -xe
pushd http_node
pub run test -p node,vm,chrome $extraOptions
pub run build_runner test -- -p node,vm,chrome
''', verbose: true);
}

@Task()
test() async {
  await test_http_io();
  await test_http_node();
  await test_http_browser();
  await test_http_redirect();
}

@Task()
fmt() async {
  await bash('''
set -xe
dartfmt . -w
''', verbose: true);
}

@DefaultTask()
help() {
  print('Quick help:');
  print('  fmt: format');
  print('  test_firebase_browser');
  print('Run a single test:');
  print('  grind test_firebase_browser -- -n get_update');
}
