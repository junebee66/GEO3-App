/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI
import Photos
import AVKit

// view single 1024x1024 image
// async load using CachedImageManager.requestImage

struct PhotoDetailView: View {
    
    var asset: PhotoAsset
    var cache: CachedImageManager?
    
    @EnvironmentObject var lobbyModel: LobbyModel
    @EnvironmentObject var app: AppModel
    
    @Environment(\.dismiss) var dismiss

    @State private var image: Image?
    @State private var imageRequestID: PHImageRequestID?
    
    @State private var showInfo = false
    
    private let imageSize = CGSize(width: 1024, height: 1024)
    
    var body: some View {
        Group {
            if let image = image {
                image
                    .resizable()
                    .scaledToFit()
                    .accessibilityLabel(asset.accessibilityLabel)
            }
            else if let player = app.videoPlayer {
                // VideoPlayer(player: AVPlayer(url:  URL(string: "https://bit.ly/swswift")!))
                VideoPlayer(player: player)
            } else {
                ProgressView()
            }
        }
        // .frame(maxWidth: .infinity, maxHeight: .infinity)
        // .ignoresSafeArea()
        .background(Color.secondary)
        // .navigationTitle("Photo")
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    showInfo.toggle()
                } label: {
                    Label("Info", systemImage: showInfo ? "info.circle.fill" : "info.circle")
                }
                Button {
                    Task {
                        await asset.delete()
                        await MainActor.run {
                            dismiss()
                        }
                    }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                Button {
                    Task {
                        await asset.setIsFavorite(!asset.isFavorite)
                    }
                } label: {
                    Label("Favorite", systemImage: asset.isFavorite ? "heart.fill" : "heart")
                }
                Button {
                    Task {
                        app.galleryModel.addGalleryAsset(phAsset: asset.phAsset)
                        await MainActor.run {
                            dismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                app.toGalleryTab()
                            }
                        }
                    }
                } label: {
                    Label("Add Photo", systemImage: "plus.app.fill")
                }
            }
        }
        .overlay(alignment: .top) {
            if let phAsset = asset.phAsset, showInfo {
                Form {
                    Text( (phAsset.creationDate?.description ?? "").prefix(19) )
                    Text( "\(phAsset.pixelWidth) x \(phAsset.pixelHeight)" )
                    if let locationDescription = phAsset.locationDescription {
                        Button {
                            app.selectedTab = .map
                        } label: {
                            Text(locationDescription)
                        }
                    }
                    if phAsset.duration > 0 {
                        Text(app.string(duration: phAsset.duration))
                    }
                }
                .frame(maxHeight: app.geometrySize.height * 0.25 )
                .padding(EdgeInsets(top: 5, leading: 30, bottom: 5, trailing: 30))
                .background(Color.secondary.colorInvert())
            }
        }
        //        .overlay(alignment: .bottom) {
        //            buttonsView()
        //                .offset(x: 0, y: -50)
        //        }
        .task {
            guard image == nil, let cache = cache else { return }
            print("PhotoDetailView isVideoMediaType", asset.isVideoMediaType)
            if let phAsset = asset.phAsset, asset.isVideoMediaType {
                app.playVideo(phAsset: phAsset)
            }
            else {
                imageRequestID = await cache.requestImage(for: asset, targetSize: imageSize) { result in
                    Task {
                        if let result = result {
                            self.image = result.image
                        }
                    }
                }
            }
        }
        .onAppear {
            print("PhotoDetailView onAppear")
            if let phAsset = asset.phAsset {
                lobbyModel.locsForUsers(firstLoc: phAsset.loc)
            }
        }
        .onDisappear {
            print("PhotoDetailView onDisappear")
            app.stopVideo()
        }
    }
}

extension PHAsset {
    var locationDescription: String? {
        guard let lat = self.location?.coordinate.latitude else { return nil }
        guard let lon = self.location?.coordinate.longitude else { return nil }
        return "\( String(format: "%.6f", lat) ) \( String(format: "%.6f", lon) )"
    }
    var loc: Location? {
        guard let lat = self.location?.coordinate.latitude as? Double else { return nil }
        guard let lon = self.location?.coordinate.longitude as? Double else { return nil }
        return Location(id: "photo", latitude: lat, longitude: lon, label: "photo")
    }
}

//        private func buttonsView() -> some View {
//            HStack(spacing: 60) {
//                Button {
//                    Task {
//                        app.galleryModel.addGalleryAsset(phAsset: asset.phAsset)
//                        await MainActor.run {
//                            // navigation with app.path
//                            // Show gallery after media added
//                            // app.path.removeLast()
//                            // app.path.append("gallery")
//                            dismiss()
//                            app.toGalleryTab()
//                        }
//                    }
//                } label: {
//                    Label("Add Photo", systemImage: "plus.app.fill")
//                        .font(.system(size: 24))
//                }
//                Button {
//                    Task {
//                        await asset.setIsFavorite(!asset.isFavorite)
//                    }
//                } label: {
//                    Label("Favorite", systemImage: asset.isFavorite ? "heart.fill" : "heart")
//                        .font(.system(size: 24))
//                }
//                Button {
//                    Task {
//                        await asset.delete()
//                        await MainActor.run {
//                            dismiss()
//                        }
//                    }
//                } label: {
//                    Label("Delete", systemImage: "trash")
//                        .font(.system(size: 24))
//                }
//            }
//            .buttonStyle(.plain)
//            .labelStyle(.iconOnly)
//            .padding(EdgeInsets(top: 20, leading: 30, bottom: 20, trailing: 30))
//            .background(Color.secondary.colorInvert())
//            .cornerRadius(15)
//        }
