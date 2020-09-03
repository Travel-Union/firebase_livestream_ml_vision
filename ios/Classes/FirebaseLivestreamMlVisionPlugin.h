#import <Flutter/Flutter.h>

#import "Firebase/Firebase.h"

@interface FLTFirebaseLivestreamMlVisionPlugin : NSObject <FlutterPlugin>
+ (void)handleError:(NSError *)error result:(FlutterResult)result;
@end

@protocol Detector
@required
- (instancetype)initWithVision:(FIRVision *)vision options:(NSDictionary *)options;
- (void)handleDetection:(FIRVisionImage *)image result:(FlutterEventSink)result;
@optional
@end

@protocol ModelManager
@required
+ (void)modelName:(NSString *)modelName result:(FlutterResult)result;
@optional
@end

@interface BarcodeDetector : NSObject <Detector>
@end

@interface FaceDetector : NSObject <Detector>
@end

@interface TextRecognizer : NSObject <Detector>
@end
