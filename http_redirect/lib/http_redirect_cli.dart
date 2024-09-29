@Deprecated('Use https://github.com/tekartik/http_redirect.dart')
library;

import 'dart:async';

import 'package:args/args.dart';
import 'package:tekartik_common_utils/int_utils.dart';
import 'package:tekartik_common_utils/log_utils.dart';
import 'package:tekartik_http_io/http_io.dart';
import 'package:tekartik_http_redirect/http_redirect.dart';

const String helpArgName = 'help';
const String corsArgName = 'cors';
const String corsHeadersArgName = 'cors-headers';
const String logArgName = 'log';
const String portArgName = 'port';
const String redirectBaseUrlArgName = 'host';
const String forwardHeaderFlagName = 'forward-headers';

Future main(List<String> arguments) async {
  var parser = ArgParser(allowTrailingOptions: true);
  parser.addFlag(helpArgName, abbr: 'h', help: 'Usage help', negatable: false);
  parser.addFlag(corsArgName, abbr: 'c', help: 'Handle CORS');
  parser.addMultiOption(corsHeadersArgName,
      abbr: 'o', help: 'CORS headers', defaultsTo: corsDefaultHeaders);
  parser.addOption(logArgName,
      abbr: 'l', help: 'Log level (fine, debug, info...)');
  parser.addOption(portArgName,
      abbr: 'p', help: 'Post number', defaultsTo: '8180');
  parser.addOption(redirectBaseUrlArgName,
      abbr: 'b', help: 'redirect baseUrl (http[s]://host:[port]/base_path');
  parser.addFlag(forwardHeaderFlagName,
      abbr: 'w', help: 'forward headers', defaultsTo: true);

  var argResults = parser.parse(arguments);

  var options = Options();
  options.handleCors = argResults[corsArgName] == true;
  options.corsHeaders = argResults[corsHeadersArgName] as List<String>;
  options.baseUrl = argResults[redirectBaseUrlArgName] as String?;
  options.forwardHeaders = argResults[forwardHeaderFlagName] as bool;

  final help = argResults[helpArgName] as bool;
  if (help) {
    print('http_proxy_exp [-p <port>] [-h <redirect_host:redirect_post>]');
    print('');
    print(parser.usage);
    return;
  }
  final logLevelText = argResults[logArgName] as String?;
  if (logLevelText != null) {
    logLevel = parseLogLevel(logLevelText);
    Logger.root.level = logLevel;
    Logger.root.info('Log level ${Logger.root.level}');
    //verbose = loA
  }

  options.baseUrl = argResults[redirectBaseUrlArgName]
      as String?; // parseHostPort(_argsResult[redirectHostArgName]);
  options.port = parseInt(argResults[portArgName]) ?? 8100;
  //var proxies = new Map<HostPort, HttpRequestProxy>();

  // var proxy = new HttpRequestProxy('localhost', 8000);
  //var host = InternetAddress.ANY_IP_V6;
  options.host = InternetAddress.anyIPv4;
  await HttpRedirectServer.startServer(
      httpFactory: httpFactoryIo, options: options);
}
