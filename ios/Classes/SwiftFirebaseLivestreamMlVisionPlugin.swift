import Flutter
import UIKit

public class SwiftFirebaseLivestreamMlVisionPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "firebase_livestream_ml_vision", binaryMessenger: registrar.messenger())
        let instance = SwiftFirebaseLivestreamMlVisionPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "ModelManager#setupLocalModel":
            break
        case "ModelManager#setupRemoteModel":
            break
        case "camerasAvailable":
            break
        case "initialize":
            break
        case "BarcodeDetector#startDetection",
             "FaceDetector#startDetection",
             "ImageLabeler#startDetection",
             "TextRecognizer#startDetection",
             "VisionEdgeImageLabeler#startLocalDetection",
             "VisionEdgeImageLabeler#startRemoteDetection":
            result(nil)
            break
        case "BarcodeDetector#close",
        "FaceDetector#close",
        "ImageLabeler#close",
        "TextRecognizer#close",
        "VisionEdgeImageLabeler#close":
            guard let args = call.arguments else {
              result("no arguments found for method: (" + call.method + ")")
              return
            }
            
            if let myArgs = args as? [String: Any],
                let handle = myArgs["handle"] as? Int {
                
                result(nil)
            } else {
                result("'handle' is required in method: " + call.method)
            }
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    
}
