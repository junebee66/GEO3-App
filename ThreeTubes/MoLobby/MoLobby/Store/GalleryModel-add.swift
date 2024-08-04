//
//  GalleryModel-add.swift
//  MoGallery
//
//  Created by jht2 on 3/11/23.
//

import FirebaseDatabase
import FirebaseStorage
import Photos
import UIKit
import SwiftUI

extension GalleryModel {
    
    func addGalleryAsset(phAsset: PHAsset?) {
        print("addGalleryAsset phAsset", phAsset ?? "-none-")
        guard let phAsset = phAsset else { return }
        print("addGalleryAsset phAsset.location", phAsset.location as Any)
        print("addGalleryAsset phAsset.mediaType", phAsset.mediaType.rawValue)
        
        // var targetSize = PHImageManagerMaximumSize
        let fullRezSize:CGSize = CGSize(width: phAsset.pixelWidth, height: phAsset.pixelHeight)
        var targetSize = fullRezSize
        let dim = Int(app.settings.storePhotoSize) ?? 0;
        if dim != 0 {
            targetSize = CGSize(width: dim, height: dim)
        }
        
        let options = PHImageRequestOptions()
        options.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true
        
        let manager = PHImageManager.default()
        
        requestImage(manager: manager,
                     fullRezSize: fullRezSize,
                     targetSize: targetSize,
                     options: options,
                     phAsset: phAsset,
                     attempts: 1)
    }
    
    func requestImage(manager: PHImageManager,
                      fullRezSize: CGSize,
                      targetSize: CGSize,
                      options: PHImageRequestOptions?,
                      phAsset: PHAsset,
                      attempts: Int) {
        print("requestImage targetSize", targetSize)
        manager.requestImage(for: phAsset, targetSize: targetSize,
                             contentMode:PHImageContentMode.default, options: options)
        { (image:UIImage?, info) in
            guard let image = image else {
                print("requestImage no image. attempts", attempts)
                print("requestImage no image. info", info ?? "-nil-")
                if attempts > 0 {
                    let options = PHImageRequestOptions()
                    options.deliveryMode = PHImageRequestOptionsDeliveryMode.fastFormat
                    options.isSynchronous = true
                    options.isNetworkAccessAllowed = true
                    self.requestImage(manager: manager,
                                      fullRezSize: fullRezSize,
                                      targetSize: targetSize,
                                      options: options,
                                      phAsset: phAsset,
                                      attempts: attempts-1)
                }
                return
            }
            print("requestImage image.size", image.size)
            guard let imageData = image.jpegData(compressionQuality: 1) else {
                print("requestImage jpegData failed")
                return;
            }
            if self.app.settings.storeFullRez {
                let options = PHImageRequestOptions()
                options.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
                options.isSynchronous = true
                options.isNetworkAccessAllowed = true
                self.requestFullRez(manager: manager,
                                    image: image,
                                    imageData: imageData,
                                    fullRezSize: fullRezSize,
                                    options: options,
                                    phAsset: phAsset,
                                    attempts: 1)
            }
            else {
                self.requestImageUpload(phAsset: phAsset,
                                        image: image,
                                        imageData: imageData,
                                        fullRezData: nil,
                                        fullRezSize: fullRezSize)
            }
        }
    }
    
    func requestFullRez(manager: PHImageManager,
                        image:UIImage,
                        imageData: Data,
                        fullRezSize: CGSize,
                        options: PHImageRequestOptions?,
                        phAsset: PHAsset,
                        attempts: Int) {
        print("requestFullRez fullRezSize", fullRezSize)
        manager.requestImage(for: phAsset, targetSize: fullRezSize,
                             contentMode:PHImageContentMode.default, options: options)
        { ( fullRezImage:UIImage?, info) in
            guard let fullRezImage = fullRezImage else {
                print("requestFullRez no image. attempts", attempts)
                print("requestFullRez no image. info", info ?? "-nil-")
                if attempts > 0 {
                    let options = PHImageRequestOptions()
                    options.deliveryMode = PHImageRequestOptionsDeliveryMode.fastFormat
                    options.isNetworkAccessAllowed = true
                    // options.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
                    // !!@ bug full rez not shown for some images from photo library
                    var fullRezSize = fullRezSize;
                    if fullRezSize.width > 1000 { fullRezSize = CGSize(width:1000, height: 1000)}
                    self.requestFullRez(manager: manager,
                                        image: image,
                                        imageData: imageData,
                                        fullRezSize: fullRezSize,
                                        options: options,
                                        phAsset: phAsset,
                                        attempts: attempts-1)
                }
                return
            }
            // in fastFormat we may get back much smaller image
            print("requestFullRez fullRezImage.size", fullRezImage.size)
            guard let fullRezData = fullRezImage.jpegData(compressionQuality: 1) else {
                print("requestFullRez jpegData failed")
                return;
            }
            self.requestImageUpload(phAsset: phAsset,
                                    image: image,
                                    imageData: imageData,
                                    fullRezData: fullRezData,
                                    fullRezSize: fullRezImage.size)
        }
    }
    
    func requestImageUpload(phAsset: PHAsset,
                            image:UIImage,
                            imageData: Data,
                            fullRezData: Data?,
                            fullRezSize: CGSize) {
        let sourceId = phAsset.localIdentifier;
        let sourceDate = phAsset.creationDate?.description ?? ""
        let imageSize = image.size;
        print("requestImageUpload imageSize", imageSize)
        var info:[String: Any] = [
            "sourceId": sourceId,
            "sourceDate": sourceDate,
            "imageWidth": imageSize.width,
            "imageHeight": imageSize.height,
        ]
        if let loc = phAsset.location {
            info["lat"] = loc.coordinate.latitude
            info["lon"] = loc.coordinate.longitude
        }
        if fullRezData != nil {
            info["fullRezWidth"] = fullRezSize.width
            info["fullRezHeight"] = fullRezSize.height
        }
        var mediaType = "";
        switch phAsset.mediaType {
        case .image:
            mediaType = "image"
        case .video:
            mediaType = "video"
        case .audio:
            mediaType = "audio"
        case .unknown:
            mediaType = "unknown"
        @unknown default:
            mediaType = "unknown"
        }
        info["mediaType"] = mediaType
        print("requestImageUpload mediaType", mediaType)
        if phAsset.isFavorite {
            info["isFavorite"] = true
        }
        if phAsset.duration > 0 {
            info["duration"] = phAsset.duration
        }
        self.uploadImageData(imageData,
                             fullRezData: fullRezData,
                             info: info)
        // !!@ Disabled
        // if phAsset.mediaType == .video {
            // export(phAsset: phAsset)
        // }
    }

} // extension GalleryModel

func export(phAsset: PHAsset) {
    print("export phAsset", phAsset)
    
    let manager = PHImageManager.default()
        
    let options = PHVideoRequestOptions()
    options.isNetworkAccessAllowed = true
    options.deliveryMode = .highQualityFormat
    
    _ = manager.requestAVAsset(
        forVideo: phAsset,
        options: options) { avasset, audioMix, info in
            print("export phAsset avasset", avasset ?? "-nil-")
            print("export phAsset info", info ?? "-nil-")
            let dirUrl = FileManager.documentsDirectory.appending(path: "videos", directoryHint: .isDirectory)
            let filem = FileManager.default
            do {
                try filem.createDirectory(at: dirUrl, withIntermediateDirectories: true)
            }
            catch {
                print("export createDirectory error", error)
            }
            let outputUrl = dirUrl.appendingPathComponent("export-1.mp4")
            do {
                try filem.removeItem(at: outputUrl)
            }
            catch {
                print("export removeItem error", error)
            }
            if let avasset {
                Task {
                    await export(video: avasset, atURL: outputUrl)
                }
            }
        }
}

// AVAssetExportPresetHighestQuality

func export(video: AVAsset,
            atURL outputURL: URL,
            withPreset preset: String = AVAssetExportPresetLowQuality,
            toFileType outputFileType: AVFileType = .mp4
            ) async {
    
    // Check the compatibility of the preset to export the video to the output file type.
    guard await AVAssetExportSession.compatibility(ofExportPreset: preset,
                                                   with: video,
                                                   outputFileType: outputFileType) else {
        print("The preset can't export the video to the output file type.")
        return
    }

    // Create and configure the export session.
    guard let exportSession = AVAssetExportSession(asset: video,
                                                   presetName: preset) else {
        print("Failed to create export session.")
        return
    }
    exportSession.outputFileType = outputFileType
    exportSession.outputURL = outputURL
    
    // Convert the video to the output file type and export it to the output URL.
    await exportSession.export()
    
    print("export(video outputURL", outputURL)
}

// https://developer.apple.com/documentation/avfoundation/avassetexportsession/export_presets
// https://developer.apple.com/documentation/photokit/phimagemanager/1616935-requestavasset

