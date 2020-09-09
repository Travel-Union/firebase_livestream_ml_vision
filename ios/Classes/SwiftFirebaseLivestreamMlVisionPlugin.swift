import Flutter
import UIKit
import AVFoundation
import VideoToolbox

public class SwiftFirebaseLivestreamMlVisionPlugin: NSObject, FlutterPlugin {
    let textureRegistry: FlutterTextureRegistry
    let channel: FlutterMethodChannel
    
    var camera: MLCamera? = nil
    
    init(channel: FlutterMethodChannel, textureRegistry: FlutterTextureRegistry) {
        self.textureRegistry = textureRegistry
        self.channel = channel
    }
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "ml_kit_flutter", binaryMessenger: registrar.messenger())
    let instance = SwiftFirebaseLivestreamMlVisionPlugin(channel: channel, textureRegistry: registrar.textures())
    let eventChannel = FlutterEventChannel(name: "ml_kit_flutter/events", binaryMessenger: registrar.messenger())
    
    registrar.addMethodCallDelegate(instance, channel: channel)
    eventChannel.setStreamHandler(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      switch call.method {
      case "availableCameras":
          let session: AVCaptureDevice.DiscoverySession = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
          
          result(session.devices.map{ (device) -> Dictionary<String, Any> in
              var lensFacing: String
              
              switch(device.position) {
              case .back:
                  lensFacing = "back"
                  break
              case .front:
                  lensFacing = "front"
                  break
              case .unspecified:
                  lensFacing = "external"
                  break
              default:
                  lensFacing = "unknown"
              }
              
              var dict: [String:Any] = [String:Any]()
              
              dict["id"] = device.uniqueID
              dict["lensFacing"] = lensFacing
              dict["orientation"] = 90
              
              return dict
          })
          break
      case "initialize":
          guard let args = call.arguments else {
              result("no arguments found for method: (" + call.method + ")")
              return
          }
          
          if let myArgs = args as? [String: Any],
              let resolution = myArgs["resolution"] as? String,
              let deviceId = myArgs["deviceId"] as? String {
              
              if(camera != nil) {
                  result(FlutterError(code: "ALREADY_RUNNING", message: "Initialize cannot be executed when camera is already running", details: ""))
                  return
              }
              
              self.initialize(resolution: resolution, deviceId: deviceId)
              self.camera?.start()
              
              var dict: [String:Any] = [String:Any]()
              
              dict["textureId"] = camera?.textureId
              dict["width"] = camera?.previewSize.width
              dict["height"] = camera?.previewSize.height
              
              result(dict)
          } else {
              result("'resolution' and 'deviceId' are required for method: (" + call.method + ")")
          }
          break
      case "BarcodeDetector#start",
           "TextRecognizer#start":
          guard camera != nil else {
              result(false)
              return
          }
          
          let contains = camera!.handlers.contains { handler in
              return call.method.starts(with: handler.name)
          }
          
          if(!contains) {
              switch call.method {
              case "TextRecognizer#start":
                  camera!.handlers.append(TextRecognitionHandler(name: "TextRecognizer"))
                  break
              case "BarcodeDetector#start":
                  camera!.handlers.append(BarcodeDetectorHandler(name: "BarcodeDetector"))
              default:
                  result(false)
                  return
              }
          }
          
          result(true)
          break
      case "BarcodeDetector#close",
           "TextRecognizer#close":
          guard camera != nil else {
              result(false)
              return
          }
          
          let index = camera!.handlers.firstIndex { handler in
              return call.method.starts(with: handler.name)
          }
          
          if(index != nil) {
              camera!.handlers.remove(at: index!)
              result(true)
          } else {
              result(false)
          }
          
          break
      case "retrieveLastFrame":
        if(camera?.pixelBuffer != nil) {
            result(UIImage(pixelBuffer: camera!.pixelBuffer!)?.jpegData(compressionQuality: 1))
        } else {
            result(nil)
        }
        break
      case "dispose":
        camera?.stop()
        result(true)
      default:
          result(FlutterMethodNotImplemented)
      }
  }
  
  private func initialize(resolution: String, deviceId: String) {
      self.camera = MLCamera(resolution: resolution, textureRegistry: self.textureRegistry, deviceId: deviceId)
  }
}

extension SwiftFirebaseLivestreamMlVisionPlugin: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        camera?.eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        camera?.eventSink = nil
        return nil
    }
}

extension UIImage {
    public convenience init?(pixelBuffer: CVPixelBuffer) {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)

        guard cgImage != nil else {
            return nil
        }

        self.init(cgImage: cgImage!)
    }
}
