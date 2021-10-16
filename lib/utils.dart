import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

extension Uint8ListMrtConversion on Uint8List {
  /// Allocates a pointer filled with the Uint8List data.
  Pointer<Uint8> allocatePointer() {
    final blob = calloc<Uint8>(this.length);

    final blobBytes = blob.asTypedList(this.length)
    ..setAll(0, this);

    return blob;
  }
}

extension Utf8MrtConversion on Pointer<Uint8> {
  Uint8List? toList(int len) {

    Uint8List? bytes;
    if (len > 0) {
      final tmp = asTypedList(len);
      bytes = Uint8List.fromList(tmp);
    }
    return bytes;
  }
}

void fillPointer(Uint8List from, Pointer<Uint8> to) {
  for (var index = 0; index < from.length; index++) {
    to[index] = from[index];
  }
}

Pointer<Int32> intListToArray(List<int> list) {
  final ptr = calloc<Int32>(list.length);
  for (var i = 0; i < list.length; i++) {
    ptr.elementAt(i).value = list[i];
  }
  return ptr;
}

Pointer<Uint8> uInt8ListToArray(List<int> list) {
  final ptr = calloc<Uint8>(list.length);
  for (var i = 0; i < list.length; i++) {
    ptr.elementAt(i).value = list[i];
  }
  return ptr;
}

Pointer<Uint16> uInt16ListToArray(List<int> list) {
  final ptr = calloc<Uint16>(list.length);
  for (var i = 0; i < list.length; i++) {
    ptr.elementAt(i).value = list[i];
  }
  return ptr;
}

Pointer<Uint32> uInt32ListToArray(List<int> list) {
  final ptr = calloc<Uint32>(list.length);
  for (var i = 0; i < list.length; i++) {
    ptr.elementAt(i).value = list[i];
  }
  return ptr;
}
