import 'dart:typed_data';

import 'package:tekartik_common_utils/common_utils_import.dart';

/// Convert data to a Uint8List if needed
Uint8List asUint8List(List<int> bytes) {
  if (bytes is Uint8List) {
    return bytes;
  }
  return Uint8List.fromList(bytes);
}

/// True if succesful.
bool isHttpStatusCodeSuccessful(int statusCode) => statusCode < 400;

/// Convert data to a string
String httpDataAsString(Object data) => httpDataAsStringOrNull(data)!;

/// Convert data to a string or return null
String? httpDataAsStringOrNull(Object? data) {
  if (data is String) {
    return data;
  } else if (data is Uint8List) {
    return utf8.decode(data);
  } else if (data is Map) {
    return jsonEncode(data);
  } else if (data is List) {
    return jsonEncode(data);
  }
  return data?.toString();
}

/// Convert data to a map
Map<String, Object?> httpDataAsMap(Object data) => httpDataAsMapOrNull(data)!;

/// Convert data to a map or return null
Map<String, Object?>? httpDataAsMapOrNull(Object? data) {
  if (data == null) {
    return null;
  }
  if (data is Map<String, Object?>) {
    return data;
  } else if (data is Map) {
    return data.cast<String, Object?>();
  } else if (data is String) {
    return parseJsonObject(data);
  }
  return parseJsonObject(httpDataAsStringOrNull(data));
}
