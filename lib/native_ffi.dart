
import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'utils.dart';

class NativeFfi {
  static const MethodChannel _channel =
      const MethodChannel('native_ffi');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}


final DynamicLibrary nativeInteropLib = Platform.isAndroid
    ? DynamicLibrary.open("libnative_interop.so")
    : DynamicLibrary.process();

final int Function(int x, int y) nativeAdd = nativeInteropLib
    .lookup<NativeFunction<Int32 Function(Int32, Int32)>>("native_add")
    .asFunction();

/* ---------------------------------------------------------------- */

typedef NativeSyncCallbackFunc = Int32 Function(Int32 n);

typedef _c_NativeSyncCallback = Void Function(
    Pointer<NativeFunction<NativeSyncCallbackFunc>> callback,
    );

typedef _dart_NativeSyncCallback = void Function(
    Pointer<NativeFunction<NativeSyncCallbackFunc>> callback,
    );

final _dart_NativeSyncCallback nativeSyncCallback = nativeInteropLib
    .lookup<NativeFunction<_c_NativeSyncCallback>>("NativeSyncCallback")
    .asFunction();

/* ---------------------------------------------------------------- */

final _initializeApi = nativeInteropLib.lookupFunction<
    IntPtr Function(Pointer<Void>),
    int Function(Pointer<Void>)>("InitDartApiDL");

ReceivePort? _receivePort;
StreamSubscription? _subscription;

void ensureNativeInitialized() {
  if (_receivePort == null) {
    WidgetsFlutterBinding.ensureInitialized();
    var nativeInited = _initializeApi(NativeApi.initializeApiDLData);
    // According to https://dart-review.googlesource.com/c/sdk/+/151525
    // flutter-1.24.0-10.1.pre+ has `DART_API_DL_MAJOR_VERSION = 2`
    assert(nativeInited == 0, 'DART_API_DL_MAJOR_VERSION != 2');
    _receivePort = ReceivePort();
    _subscription = _receivePort!.listen(_handleNativeMessage);
    _registerSendPort(_receivePort!.sendPort.nativePort);
  }
}

void dispose() {
  // TODO _unregisterReceivePort(_receivePort.sendPort.nativePort);
  _subscription?.cancel();
  _receivePort?.close();
}

final _registerSendPort = nativeInteropLib.lookupFunction<
    Void Function(Int64 sendPort),
    void Function(int sendPort)>('RegisterSendPort');


void _handleNativeMessage(message) {
  var ptr = Pointer.fromAddress(message);
  Uint8List? bytes;
  if (ptr != nullptr) {
    final str = ptr.cast<Utf8>().toDartString();
    print('Response message: $str');

    bytes = ptr.cast<Uint8>().toList(200);
    calloc.free(ptr);
    // _freeCppPtr(ptr.cast<IntPtr>());
  }

  ptr = nullptr;
  print('Response bytes: $bytes');
}

typedef NativeAsyncCallbackFunc = Void Function();

typedef _c_NativeAsyncCallback = Void Function(
    Pointer<NativeFunction<NativeAsyncCallbackFunc>> callback,
    );

typedef _dart_NativeAsyncCallback = void Function(
    Pointer<NativeFunction<NativeAsyncCallbackFunc>> callback,
    );

final _dart_NativeAsyncCallback nativeAsyncCallback = nativeInteropLib
    .lookup<NativeFunction<_c_NativeAsyncCallback>>("NativeAsyncCallback")
    .asFunction();

typedef _c_free_pointer = Void Function(Pointer<IntPtr> ptr);
typedef _dart_free_pointer = void Function(Pointer<IntPtr> ptr);

final _c_FreeCtsMrtEvent_ptr = nativeInteropLib
    .lookup<NativeFunction<_c_free_pointer>>(
    'FreeCppPointer');

final _dart_free_pointer _freeCppPtr = _c_FreeCtsMrtEvent_ptr.asFunction<_dart_free_pointer>();