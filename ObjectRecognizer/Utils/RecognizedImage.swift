//
//  RecognizedImage.swift
//  ObjectRecognizer
//
//  Created by Admin on 07/07/2017.
//  Copyright © 2017 Mattowy. All rights reserved.
//

import UIKit
import CoreML

class RecognizedImage {
    private var _image: UIImage!
    private var _newImage: UIImage!
    private var _pixelBuffer: CVPixelBuffer?
    
    init(_ inputImage: UIImage) {
        _image = inputImage
    }
    
    var image: UIImage {
        if _newImage == nil {
            transformImage()
        }
        return _newImage
    }
    
    var pixelBuffer: CVPixelBuffer {
        if _pixelBuffer == nil {
            transformImage()
        }
        
        return _pixelBuffer!
    }
    
    func transformImage() {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 299, height: 299), true, 2.0)
        _image.draw(in: CGRect(x: 0, y: 0, width: 299, height: 299))
        _newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(_newImage.size.width), Int(_newImage.size.height), kCVPixelFormatType_32ARGB, attrs, &_pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return
        }
        CVPixelBufferLockBaseAddress(_pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(_pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(_newImage.size.width), height: Int(_newImage.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(_pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) //3
        
        context?.translateBy(x: 0, y: _newImage.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        _newImage.draw(in: CGRect(x: 0, y: 0, width: _newImage.size.width, height: _newImage.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(_pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
    }
}

