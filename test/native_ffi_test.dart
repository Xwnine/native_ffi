import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_ffi/native_ffi.dart';

void main() {
  const MethodChannel channel = MethodChannel('native_ffi');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await NativeFfi.platformVersion, '42');
  });
}
