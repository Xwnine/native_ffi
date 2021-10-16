#import "NativeFfiPlugin.h"
#if __has_include(<native_ffi/native_ffi-Swift.h>)
#import <native_ffi/native_ffi-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "native_ffi-Swift.h"
#endif

@implementation NativeFfiPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftNativeFfiPlugin registerWithRegistrar:registrar];
}
@end
