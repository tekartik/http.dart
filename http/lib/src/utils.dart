import 'dart:typed_data';

Uint8List asUint8List(List<int> bytes) {
  if (bytes is Uint8List) {
    return bytes;
  }
  return Uint8List.fromList(bytes);
}

/// True if succesful.
bool isHttpStatusCodeSuccessful(int statusCode) => statusCode < 400;
