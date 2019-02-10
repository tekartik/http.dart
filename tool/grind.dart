import 'dart:async';

import 'package:grinder/grinder.dart';
import 'package:process_run/process_run.dart';
import 'package:tekartik_build_utils/bash/bash.dart';

// ignore_for_file: non_constant_identifier_names

String extraOptions = '';

void main(List<String> args) {
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
Future test_http_browser() async {
  await bash('''
set -xe
pushd http_browser
pub run test -p chrome -r expanded $extraOptions
pub run build_runner test --fail-on-severe -- -p chrome -r expanded $extraOptions
''', verbose: true);
}

@Task()
Future test_http_io() async {
  await bash('''
set -xe
pushd http_io
pub run test $extraOptions
pub run build_runner test
''', verbose: true);
}

@Task()
Future test_http_node() async {
  await bash('''
set -xe
pushd http_node
pub run test -p node $extraOptions
pub run build_runner test -- -p node
''', verbose: true);
}

@Task()
Future test_http_redirect() async {
  await bash('''
set -xe
pushd http_node
pub run test -p node,vm,chrome $extraOptions
pub run build_runner test -- -p node,vm,chrome
''', verbose: true);
}

@Task()
Future test() async {
  await test_http_io();
  await test_http_node();
  await test_http_browser();
  await test_http_redirect();
}

@Task()
Future fmt() async {
  await bash('''
set -xe
dartfmt . -w
''', verbose: true);
}

@DefaultTask()
void help() {
  print('Quick help:');
  print('  fmt: format');
  print('  test_firebase_browser');
  print('Run a single test:');
  print('  grind test_firebase_browser -- -n get_update');
}
