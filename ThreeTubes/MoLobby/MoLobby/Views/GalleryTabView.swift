//
//  GalleryView.swift
//

// Display grid of images from database mo-gallery

import SwiftUI

let myIconFont = Font
    .system(size: 12)
//    .monospaced()

struct GalleryTabView: View {
    
    @State private var selection: String?
    @State private var showingAlert = false
    @State private var showingAddRandomAlert = false
    
    @EnvironmentObject var lobbyModel: LobbyModel
    @EnvironmentObject var galleryModel: GalleryModel
    @EnvironmentObject var metaModel: MetaModel
    @EnvironmentObject var app: AppModel
    
    @Environment(\.displayScale) private var displayScale
    @Environment(\.dismiss) var dismiss
    
    // private static let itemCornerRadius = 15.0
    private static let itemSpacing = 2.0
    private static let itemSize = CGSize(width: 94, height: 94)
    private var imageSize: CGSize {
        return CGSize(width: Self.itemSize.width * min(displayScale, 2),
                      height: Self.itemSize.height * min(displayScale, 2))
    }
    
    private let columns = [
        GridItem(.adaptive(minimum: itemSize.width, maximum: itemSize.height), spacing: itemSpacing)
    ]
    
    var body: some View {
        NavigationStack(path: $galleryModel.path) {
            ScrollView {
                // !!@ metaEntry update no seen when GalleryHeaderView used
                // GalleryHeaderView(metaModel: metaModel, metaEntry: metaEntry)
                if let metaEntry = app.galleryModel.currentMeta {
                    NavigationLink {
                        MetaDetailView(metaEntry: metaEntry)
                    } label: {
                        VStack {
                            Text(galleryModel.countDisplayText())
                            if  !metaEntry.caption.isEmpty {
                                Text(metaEntry.caption)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
                LazyVGrid(columns: columns, spacing: Self.itemSpacing) {
                    ForEach(galleryModel.gallery) { item in
                        NavigationLink(value: item.id) {
                            MediaThumbView(item: item, itemSize: Self.itemSize)
                        }
                        .buttonStyle(.borderless)
                    }
                }
                .padding([.vertical], Self.itemSpacing)
            }
            .navigationBarTitleDisplayMode(.inline)
            // .statusBar(hidden: false)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    NavigationLink(value: "") {
                        Label(app.galleyTitle, systemImage: "rectangle.stack")
                            .labelStyle(.titleAndIcon)
                    }
                    Button(action: {
                        showingAlert = true
                    }) {
                        Image(systemName: "trash")
                    }
                    Button(action: {
                        if !app.settings.randomAddWarning {
                            addRandomMedia()
                        }
                        else {
                            showingAddRandomAlert = true
                        }
                    }) {
                        // plus.square.fill.on.square.fill plus.diamond.fill
                        Label("Random", systemImage: "plus.diamond.fill")
                    }
                }
            }
            .alert(galleryModel.deleteWarning(), isPresented:$showingAlert) {
                Button("OK") {
                    showingAlert = false
                    galleryModel.deleteAll()
                    // dismiss();
                }
                Button("Cancel", role: .cancel) {
                    showingAlert = false
                }
            }
            .alert("Are you sure you want to ADD a random photo from your Photo Library?", isPresented:$showingAddRandomAlert) {
                Button("OK") {
                    showingAddRandomAlert = false
                    addRandomMedia()
                }
                Button("OK - dont ask again") {
                    showingAddRandomAlert = false
                    app.settings.randomAddWarning = false
                    app.saveSettings()
                    addRandomMedia()
                }
                Button("Cancel", role: .cancel) {
                    showingAddRandomAlert = false
                }
            }
            .onAppear {
                selection = app.settings.storeGalleryKey
                //                if let selection {
                //                    app.addGalleryKey(name: selection)
                //                }
            }
            .navigationDestination(for: String.self) { id in
                if id.isEmpty {
                    GalleryPickerView(galleryKeys: app.settings.galleryKeys,
                                      selection: $selection)
                    
                }
                else if let item = galleryModel.itemFor(id: id) {
                    MediaDetailView(item: item,
                                    priorSelection: app.settings.storeGalleryKey)
                }
            }
        }
    }
    
//    func mediaItemForDetail(_ item :MediaModel) -> MediaModel {
//        MediaModel(id: item.id,
//                   dict: [
//                    "caption": item.caption,
//                    "previewUrl": item.previewUrl,
//                    "loadPreviewUrl": item.loadPreviewUrl
//                   ])
//    }
    
    private func addRandomMedia() {
        Task {
            guard let asset = app.photosModel.nextRandomAsset() else {
                print("GalleryView no assets")
                return
            }
            galleryModel.addGalleryAsset(phAsset: asset.phAsset)
        }
    }
}

// GalleryHeaderView
struct GalleryHeaderView: View {
    var metaModel: MetaModel;
    var metaEntry: MetaEntry;
    
    @EnvironmentObject var app: AppModel
    
    var body: some View {
        NavigationLink {
            MetaDetailView(metaEntry: metaEntry)
        } label: {
            VStack {
                Text(app.galleryModel.countDisplayText())
                if  !metaEntry.caption.isEmpty {
                    Text(metaEntry.caption)
                        .lineLimit(1)
                }
            }
        }
    }
}

struct MediaThumbView: View {
    var item: MediaModel
    var itemSize: CGSize
    
    var body: some View {
        AsyncImage(url: URL(string: item.mediaPath))
        { image in
            image.resizable()
                .scaledToFill()
            // .scaledToFit()
            
        } placeholder: {
            ProgressView()
        }
        .aspectRatio(contentMode: .fill)
        // .aspectRatio(contentMode: .fit)
        .frame(width: itemSize.width, height: itemSize.height)
        .clipped()
        .overlay(alignment: .bottomLeading) {
            HStack {
                if item.isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 1)
                        .font(.callout)
                        .offset(x: 4, y: -4)
                }
                if item.isVideoMediaType {
                    Image(systemName: "video.fill")
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 1)
                        .font(.callout)
                        .offset(x: 4, y: -4)
                }
                if !item.caption.isEmpty {
                    let lines = item.caption.split(separator: "\n")
                    let str = lines[0]
                    Text(str)
                        .font(.footnote)
                        .padding(2)
                        .foregroundColor(.white)
                        .background(Color(.lightGray))
                }
            }
        }
    }
}

//struct MediaCollectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        GalleryView()
//    }
//}

//                    NavigationLink(value: "") {
//                        Label(app.galleyTitle, systemImage: "rectangle.stack")

//                    NavigationLink {
//                        GalleryPickerView(galleryKeys: app.settings.galleryKeys,
//                                          selection: $selection)
//                    } label: {
//                        Label(app.galleyTitle, systemImage: "rectangle.stack")
//                            .labelStyle(.titleAndIcon)
//                        // Label("Gallery List", systemImage: "rectangle.stack")
//
//                    }

//  NavigationLink {
//      MediaDetailView(lobbyModel: lobbyModel,
//          item: item,
//              priorSelection: app.settings.storeGalleryKey)
//      } label: {
//          MediaThumbView(item: item, itemSize: Self.itemSize)
//  }
