/*
 See the License.txt file for this sample’s licensing information.
 */

import AVFoundation
import SwiftUI


final class CameraModel: ObservableObject {
    
    var photoInfoProvided: ((PhotoInfo) -> ())?
    var previewImageProvided: ((Image?) -> ())?
    
    private let cameraCapture = CameraCapture()
            
    init() {
        Task {
            await handleCameraPreviews()
        }
        Task {
            await handleCameraPhotos()
        }
    }

    func refresh() {
        Task {
            await cameraCapture.start()
        }
    }
    
    func takePhoto() {
        cameraCapture.takePhoto()
    }
    
    func switchCaptureDevice() {
        cameraCapture.switchCaptureDevice()
    }

    var isPreviewPaused: Bool {
        get { cameraCapture.isPreviewPaused }
        set { cameraCapture.isPreviewPaused = newValue }
    }

    func handleCameraPreviews() async {
        let imageStream = cameraCapture.previewStream
            .map { $0.image }
        
        for await image in imageStream {
            Task { @MainActor in
                previewImageProvided?(image)
            }
        }
    }
    
    func handleCameraPhotos() async {
        let unpackedPhotoStream = cameraCapture.photoStream
            .compactMap { self.unpackPhoto($0) }
        
        for await photoInfo in unpackedPhotoStream {
            Task { @MainActor in
                photoInfoProvided?(photoInfo)
            }
        }
    }
    
    private func unpackPhoto(_ photo: AVCapturePhoto) -> PhotoInfo? {
        
         guard let imageData = photo.fileDataRepresentation() else { return nil }
        
        // get cgImage and orient for possible later resizing
        // https://developer.apple.com/documentation/avfoundation/avcapturephoto/2873963-cgimagerepresentation
        guard let cgImage = photo.cgImageRepresentation() else { return nil }
        
        // get the orientation in UIImage format
        guard let metadataOrientation = photo.metadata[String(kCGImagePropertyOrientation)] as? UInt32,
              let cgImageOrientation2 = CGImagePropertyOrientation(rawValue: metadataOrientation)  else { return nil }
        let orient = UIImage.Orientation(cgImageOrientation2)
        
        // let uiImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: orient);
        // let targetSize = CGSize(width: 100, height: 100)
        // let nimage = uiImage.scalePreservingAspectRatio(targetSize: targetSize)
        // guard let nimageData = nimage.jpeg else { return nil }
        // let imageData = nimageData;
        
        guard let previewCGImage = photo.previewCGImageRepresentation(),
              let metadataOrientation = photo.metadata[String(kCGImagePropertyOrientation)] as? UInt32,
              let cgImageOrientation = CGImagePropertyOrientation(rawValue: metadataOrientation) else { return nil }
        let imageOrientation = Image.Orientation(cgImageOrientation)
        let thumbnailImage = Image(decorative: previewCGImage, scale: 1, orientation: imageOrientation)
        
        let photoDimensions = photo.resolvedSettings.photoDimensions
        let imageSize = (width: Int(photoDimensions.width), height: Int(photoDimensions.height))
        let previewDimensions = photo.resolvedSettings.previewDimensions
        let thumbnailSize = (width: Int(previewDimensions.width), height: Int(previewDimensions.height))
        
        return PhotoInfo(thumbnailImage: thumbnailImage, thumbnailSize: thumbnailSize,
                         imageData: imageData,
                         imageSize: imageSize,
                         cgImage: cgImage,
                         orient: orient)
    }
        
}

struct PhotoInfo {
    var thumbnailImage: Image
    var thumbnailSize: (width: Int, height: Int)
    var imageData: Data
    var imageSize: (width: Int, height: Int)
    var cgImage: CGImage
    var orient: UIImage.Orientation
}

fileprivate extension CIImage {
    var image: Image? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else { return nil }
        return Image(decorative: cgImage, scale: 1, orientation: .up)
    }
}

fileprivate extension Image.Orientation {
    
    init(_ cgImageOrientation: CGImagePropertyOrientation) {
        switch cgImageOrientation {
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
