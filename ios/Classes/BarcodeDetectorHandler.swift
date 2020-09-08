//
//  BarcodeDetectorHandler.swift
//  firebase_core
//
//  Created by Lukas Plachtinas on 2020-09-08.
//

import Foundation
import MLKitVision
import MLKitBarcodeScanning
import os.log

class BarcodeDetectorHandler: ImageHandler {
    let barcodeScanner: BarcodeScanner!
    var name: String!
    var processing: Atomic<Bool>
    
    init(name: String) {
        self.name = name
        self.processing = Atomic<Bool>(false)
        self.barcodeScanner = BarcodeScanner.barcodeScanner(options: BarcodeScannerOptions(formats: .all))
    }
    
    func onImage(image: VisionImage, callback: @escaping (Dictionary<String, Any>) -> Void) {
        self.processing.value = false
        
        self.barcodeScanner.process(image) { features, error in
            guard error == nil, let barcodes = features else {
                os_log("Error decoding barcode %@", error!.localizedDescription)
                return
            }
            
            var barcodeList = [Any]()
            
            for barcode in barcodes {
                let displayValue = barcode.displayValue
                let rawValue = barcode.rawValue
                
                barcodeList.append(["value": rawValue ?? "", "displayValue": displayValue ?? ""])
            }
            
            if(barcodeList.count > 0) {
                callback(["eventType": "barcodeDetection", "data": barcodeList])
            }
        }
    }
}
