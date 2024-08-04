//
//  imageUtils.swift
//  CaptureCameraStorage
//
//  Created by jht2 on 12/18/22.
//

import AVFoundation

// https://rockyshikoku.medium.com/resize-cgimage-baf23a0f58ab

extension CGImage {
    func resize(size:CGSize) -> CGImage? {
        let width: Int = Int(size.width)
        let height: Int = Int(size.height)
        
        let bytesPerPixel = self.bitsPerPixel / self.bitsPerComponent
        let destBytesPerRow = width * bytesPerPixel
        
        guard let colorSpace = self.colorSpace else { return nil }
        guard let context = CGContext(data: nil,
            width: width, height: height,
            bitsPerComponent: self.bitsPerComponent,
            bytesPerRow: destBytesPerRow,
            space: colorSpace,
            bitmapInfo: self.alphaInfo.rawValue)
        else { return nil }
        
        context.interpolationQuality = .high
        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        return context.makeImage()
    }
}

// https://www.advancedswift.com/resize-uiimage-no-stretching-swift/

import UIKit

extension UIImage {
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        
        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )
        
        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        return scaledImage
    }
    
}

extension UIImage {
    var jpeg: Data? {
        jpegData(compressionQuality: 1)
    }
}

extension UIImage.Orientation {
    init(_ cgOrientation: CGImagePropertyOrientation) {
        switch cgOrientation {
            case .up: self = .up
            case .upMirrored: self = .upMirrored
            case .down: self = .down
            case .downMirrored: self = .downMirrored
            case .left: self = .left
            case .leftMirrored: self = .leftMirrored
            case .right: self = .right
            case .rightMirrored: self = .rightMirrored
        }
    }
}

