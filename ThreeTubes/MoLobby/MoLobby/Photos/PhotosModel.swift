/*
 See the License.txt file for this sample’s licensing information.
 */

import AVFoundation
import SwiftUI
import os.log

// for fetch album names, extracted from DICE PhotosLibrary
import Photos

final class PhotosModel: ObservableObject {
        
    var photoCollection: PhotoCollection?
    
    @Published var viewfinderImage: Image?
    @Published var thumbnailImage: Image?
    @Published var albumNames: [String] = []

    @Published var isLoading: Bool = false
    @Published var errorFound: Bool = false
    @Published var errInfo: Error?

    var isPhotosLoaded = false

    unowned var app: AppModel
    init(_ app:AppModel) {
        self.app = app
    }

    // Array of randomly shuffled indices for non-repeating selection from nextRandomAsset
    var selectionIndices: [Int]?
    var selectionIndex = 0
    var selectionLast = -1
    
    var photoCollectionTitle: String {
        photoCollection!.albumName ?? "Photo Library"
    }
    
    func nextRandomAsset() -> PhotoAsset? {
        guard let assets = photoCollection?.photoAssets, assets.count > 0 else {
            print("nextRandomAsset no assets")
            return nil
        }
        // reshuffle when we wrap around and avoid two of the same in a row
        if selectionIndices == nil || selectionIndex >= selectionIndices!.count {
            selectionIndices = Array(0...assets.count-1)
            selectionIndices!.shuffle()
            selectionIndex = 0
            if selectionLast == selectionIndices![0] {
                selectionIndex = 1 % selectionIndices!.count
            }
        }
        guard let selectionIndices else { return nil }
        // Int.random(in: 0..<assets.count)
        var index = selectionIndex
        selectionIndex = selectionIndex + 1
        index = selectionIndices[index % selectionIndices.count] % assets.count;
        print("nextRandomAsset assets.count", assets.count, "index", index)
        selectionLast = index
        return assets[index]
    }

    func refresh() {
        selectionIndex = 0
        selectionIndices = nil
        let albumName = app.settings.photoAlbum
        print("PhotosModel refresh photoAlbum", albumName)
        // !!@ app.photoLibLimited
        if albumName == "-Photo Library-" || app.photoLibLimited {
            photoCollection = PhotoCollection(self, smartAlbum: .smartAlbumUserLibrary)
            // photoCollection = PhotoCollection(self, smartAlbum: .any)
        }
        else {
            photoCollection = PhotoCollection(self, albumNamed: albumName, createIfNotFound: false)
            // photoCollection = PhotoCollection(albumNamed: albumName, createIfNotFound: true)
        }
        isPhotosLoaded = false
        
        Task {
            await loadPhotos()
            await loadThumbnail()
            await loadAlbumNames()
        }
    }
    
    func loadAlbumNames() async {
        let userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        // !!@ album are saved by title only
        // to deal with duplicate names we need to also store associated localIdentifier
        var arr: [String] = ["-Photo Library-"]
        for index in 0..<userCollections.count {
            let col = userCollections.object(at: index);
            let title = col.localizedTitle ?? ""
            // print("PhotosModel  setup index=", index, "localizedTitle=", title, "id=", col.localIdentifier)
            arr.append(title)
        }
        let sortedItems = arr.sorted(by: { $0 < $1 })
        Task { @MainActor in
            self.albumNames = sortedItems
//            for ent in albumNames {
//                print(ent)
//            }
            // print("PhotosModel albumNames", albumNames)
            print("albumNames count", albumNames.count)
        }
    }

    func savePhoto(photoInfo: PhotoInfo) {
        thumbnailImage = photoInfo.thumbnailImage
        Task {
            do {
                // try await photoCollection.addImage(imageData)
                let imageData = app.galleryModel.getSaveImageData(photoInfo: photoInfo)
                if let imageData {
                    try await photoCollection!.addImage(imageData)
                    print("PhotosModel Added data")
                }
            } catch let error {
                print("PhotosModel Failed Add data: \(error.localizedDescription)")
            }
        }
    }

    func loadPhotos() async {
        guard !isPhotosLoaded else {
            print("loadPhotos isPhotosLoaded", isPhotosLoaded)
            return
        }
        
        let authorized = await PhotoLibrary.checkAuthorization()
        guard authorized.0 else {
            print("Photo library access was not authorized.")
            return
        }
        app.photoLibLimited = authorized.1 == .limited
        
        Task {
            do {
                try await self.photoCollection!.load()
                await self.loadThumbnail()
            } catch let error {
                print("Failed to load photo collection: \(error.localizedDescription)")
            }
            self.isPhotosLoaded = true
        }
    }
    
    func loadThumbnail() async {
        guard let asset = photoCollection!.photoAssets.first  else { return }
        let targetSize = CGSize(width: 256, height: 256)
        await photoCollection!.cache.requestImage(for: asset, targetSize: targetSize)  { result in
            if let result = result {
                Task { @MainActor in
                    self.thumbnailImage = result.image
                }
            }
        }

    }
}

//struct PhotoInfo {
//    var thumbnailImage: Image
//    var thumbnailSize: (width: Int, height: Int)
//    var imageData: Data
//    var imageSize: (width: Int, height: Int)
//    var cgImage: CGImage
//    var orient: UIImage.Orientation
//}
//
//fileprivate extension CIImage {
//    var image: Image? {
//        let ciContext = CIContext()
//        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else { return nil }
//        return Image(decorative: cgImage, scale: 1, orientation: .up)
//    }
//}
//
//fileprivate extension Image.Orientation {
//
//    init(_ cgImageOrientation: CGImagePropertyOrientation) {
//        switch cgImageOrientation {
//        case .up: self = .up
//        case .upMirrored: self = .upMirrored
//        case .down: self = .down
//        case .downMirrored: self = .downMirrored
//        case .left: self = .left
//        case .leftMirrored: self = .leftMirrored
//        case .right: self = .right
//        case .rightMirrored: self = .rightMirrored
//        }
//    }
//}
//
