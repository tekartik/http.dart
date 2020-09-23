import 'package:tekartik_http/http.dart';
import 'package:tekartik_common_utils/env_utils.dart';
import 'package:tekartik_http_io/http_io.dart';
import 'package:tekartik_http_node/http_node.dart';

HttpFactory get httpFactoryUniversal =>
    isRunningAsJavascript ? httpFactoryNode : httpFactoryIo;
