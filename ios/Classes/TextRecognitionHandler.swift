//
//  TextRecognitionHandler.swift
//  firebase_core
//
//  Created by Lukas Plachtinas on 2020-09-08.
//

import MLKitVision
import MLKitTextRecognition
import os.log

class TextRecognitionHandler : ImageHandler {
    let textRecognizer: TextRecognizer!
    var name: String!
    var processing: Atomic<Bool>
    
    init(name: String) {
        self.name = name
        self.processing = Atomic<Bool>(false)
        self.textRecognizer = TextRecognizer.textRecognizer()
    }
    
    func onImage(image: VisionImage, callback: @escaping (Dictionary<String, Any>) -> Void) {
        self.textRecognizer.process(image) { result, error in
            self.processing.value = false
            
            guard error == nil, let result = result else {
                os_log("Error decoding barcode %@", error!.localizedDescription)
                return
            }
            
            let resultText = result.text
            
            var blocks = [[String:Any]]()
            
            for block in result.blocks {
                var blockData = [String:Any]()
                
                blockData["text"] = block.text
                blockData["languages"] = block.recognizedLanguages.map { lang in
                    return lang.toString()
                }
                
                blockData["left"] = block.frame.origin.x
                blockData["top"] = block.frame.origin.y
                blockData["width"] = block.frame.size.width
                blockData["height"] = block.frame.size.height
                
                var blockLines = [[String:Any]]()
                
                for line in block.lines {
                    var lineData = [String:Any]()
                    
                    lineData["text"] = line.text
                    lineData["languages"] = line.recognizedLanguages.map { lang in
                        return lang.toString()
                    }
                    lineData["left"] = line.frame.origin.x
                    lineData["top"] = line.frame.origin.y
                    lineData["width"] = line.frame.size.width
                    lineData["height"] = line.frame.size.height
                    
                    var lineElements = [[String:Any]]()
                    
                    for element in line.elements {
                        var elementData = [String:Any]()
                        
                        elementData["text"] = element.text
                        elementData["left"] = element.frame.origin.x
                        elementData["top"] = element.frame.origin.y
                        elementData["width"] = element.frame.size.width
                        elementData["height"] = element.frame.size.height
                        
                        lineElements.append(elementData)
                    }
                    
                    lineData["elements"] = lineElements
                    
                    blockLines.append(lineData)
                }
                
                blockData["lines"] = blockLines
                
                blocks.append(blockData)
            }
            
            if(resultText.count > 0) {
                callback(["eventType": "textRecognition", "data": ["text": resultText, "blocks": blocks]])
            }
        }
    }
}

extension TextRecognizedLanguage {
    func toString() -> String? {
        self.languageCode;
    }
}
