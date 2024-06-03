import 'dart:async';

import 'package:async/async.dart';
export 'echo_server_vm.dart' if (dart.library.js_interop) 'echo_server_js.dart';

extension StreamQueueOfNullableObjectExtension on StreamQueue<Object?> {
  /// When run under dart2wasm, JSON numbers are always returned as [double].
  Future<int> get nextAsInt async => ((await next) as num).toInt();
}
