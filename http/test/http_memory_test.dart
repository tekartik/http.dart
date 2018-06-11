// Copyright (c) 2017, Alexandre Roux. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library tekartik_http.http_memory_test;

import 'package:tekartik_http/http_client.dart';
import 'package:tekartik_http/http_server.dart';
import 'package:tekartik_http_test/http_test.dart';
//import 'dart:io';

void main() {
  run(httpClientFactoryMemory, httpServerFactoryMemory);
}
