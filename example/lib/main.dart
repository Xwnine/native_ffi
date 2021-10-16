import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:native_ffi/native_ffi.dart';

void main() {
  ensureNativeInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            RaisedButton(
              child: Text('Test'),
              onPressed: () {
                var asyncFunc = Pointer.fromFunction<NativeAsyncCallbackFunc>(asyncCallback);
                nativeAsyncCallback(asyncFunc);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------------------------------------------------------- */

void asyncCallback() {
  print('asyncCallback called');
}