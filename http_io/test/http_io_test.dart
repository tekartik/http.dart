// Copyright (c) 2017, Alexandre Roux. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

@TestOn('vm')
library _;

import 'package:tekartik_http_io/http_io.dart';
import 'package:tekartik_http_test/http_test.dart';
import 'package:test/test.dart';
//import 'dart:io';

void main() {
  run(httpFactoryIo);
}
