#import "FirebaseLivestreamMlVisionPlugin.h"
#if __has_include(<firebase_livestream_ml_vision/firebase_livestream_ml_vision-Swift.h>)
#import <firebase_livestream_ml_vision/firebase_livestream_ml_vision-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "firebase_livestream_ml_vision-Swift.h"
#endif

@implementation FirebaseLivestreamMlVisionPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFirebaseLivestreamMlVisionPlugin registerWithRegistrar:registrar];
}
@end
