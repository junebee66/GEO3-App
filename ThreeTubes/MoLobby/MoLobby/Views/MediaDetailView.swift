//
//  MediaEditView.swift
//  MoGallery
//
//  Created by jht2 on 12/22/22.
//

// Present an image from the gallary from Firebase storage
//  + button to delete

import SwiftUI
import AVKit
import Photos
import YouTubePlayerKit

struct MediaDetailView: View {
    
    @ObservedObject var item: MediaModel;
    //    @ObservedObject var editItem: MediaModel
    var priorSelection: String
    
    @EnvironmentObject var lobbyModel: LobbyModel
    @EnvironmentObject var galleryModel: GalleryModel
    @EnvironmentObject var app: AppModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showingAlert = false
    @State private var showInfo = false
    @State private var isSharing = false
    
    @State private var selection: String?
    @State private var imageThumb: UIImage?
    
//    @State private var deleted = false
    
    var body: some View {
        Group {
            VStack {
                if let player = app.youTubePlayer {
                    YouTubePlayerView(player) { state in
                        switch state {
                        case .idle:
                            ProgressView()
                        case .ready:
                            EmptyView()
                        case .error(let error):
                            Text(verbatim: "YouTube player error \(error)")
                        }
                    }
                }
                else if let player = app.videoPlayer {
                    VideoPlayer(player: player)
                }
                else if item.previewUrl.hasPrefix("https://") && item.loadPreviewUrl {
                    // load web site
                    let url = URL(string: item.previewUrl)!
                    WebView(request: URLRequest(url: url))
                }
                else {
                    let imageURL = URL(string: item.mediaPathDetail)
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .scaledToFit()
                        
                    } placeholder: {
                        ProgressView()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // .ignoresSafeArea()
        .background(Color.secondary)
        // .navigationTitle("Media")
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // navigationBarLeading
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                topButtons()
            }
        }
        .overlay(alignment: .top) {
            if showInfo {
                showInfoOverlay()
            }
        }
        .overlay(alignment: .bottom) {
            // Dont show caption overlay if previewUrl is present
            if !item.caption.isEmpty && item.previewUrl.isEmpty {
                Text(item.caption)
                    .frame(width: app.geometrySize.width)
                    .padding()
                    .foregroundColor(.white)
                // .background(Color(.lightGray))
                    .background(Color.secondary.colorInvert())
            }
        }
        .alert("Are you sure you want to delete this photo?", isPresented:$showingAlert) {
            Button("OK") {
                showingAlert = false
                dismiss()
                app.galleryModel.deleteMedia(mediaItem: item)
                // deleted = true
            }
            Button("Cancel", role: .cancel) {
                showingAlert = false
            }
        }
        .onChange(of: selection) { newState in
            print("MediaDetailView onChange priorSelection", priorSelection, "newState", newState ?? "-nil-")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                dismiss()
            }
        }
        .onAppear {
            print("MediaDetailView onAppear")
            lobbyModel.locsForUsers(firstLoc: item.loc)
            // priorCaption = item.caption
            // priorPreviewUrl = item.previewUrl
            // priorLoadPreviewUrl = item.loadPreviewUrl
        }
        .onDisappear {
            print("MediaDetailView onDisappear")
            app.stopVideo()
//            if !deleted {
//                Task {
//                    app.galleryModel.updateMedia(media: item)
//                }
//            }
        }
        .task {
            imageThumb = await imageFor(string: item.mediaPath)
            print("imageThumb", imageThumb ?? "-nil-")
            if !item.previewUrl.isEmpty  && item.loadPreviewUrl {
                // Play remote video
                app.playVideo(url: item.previewUrl)
            }
            else if let sourceId = item.sourceId, item.isVideoMediaType {
                // Play local movie video
                let asset = PhotoAsset(identifier: sourceId)
                guard let phAsset = asset.phAsset else {
                    print("MediaDetailView !!@ Missing sourceId", sourceId)
                    return
                }
                app.playVideo(phAsset: phAsset)
            }
        }
    }
    
    func showInfoOverlay() -> some View {
        Form {
            NavigationLink {
                if let user = lobbyModel.user(uid: item.uid) {
                    UserDetailView(user: user )
                }
            } label: {
                Text(item.authorEmail)
            }
            if let sourceDate = item.sourceDate {
                Text(sourceDate.prefix(19))
            }
            let homeRefLabel = app.homeRefLabel(item: item)
            Text("\(item.width) x \(item.height) \(homeRefLabel)" )
            if let locationDescription = item.locationDescription {
                Button {
                    app.selectedTab = .map
                } label: {
                    Text(locationDescription)
                }
            }
            if item.duration > 0 {
                Text(app.string(duration: item.duration))
            }
            Section {
                Text("Caption")
                TextField("", text: $item.caption, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                Toggle("Preview url", isOn: $item.loadPreviewUrl)
                TextField("", text: $item.previewUrl, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
            }
        }
        .frame(maxHeight: app.geometrySize.height * 0.6 )
        .font(.subheadline)
        .padding(EdgeInsets(top: 5, leading: 30, bottom: 5, trailing: 30))
        .background(Color.secondary.colorInvert())
    }
    
    func topButtons() -> some View {
        Group {
            Button {
                showInfo.toggle()
                if !showInfo {
                    app.galleryModel.updateMedia(media: item)
                }
            } label: {
                Label("Info", systemImage: showInfo ? "info.circle.fill" : "info.circle")
            }
            Button {
                showingAlert = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
            Button(action: {
                isSharing = true
            }) {
                Image(systemName: "square.and.arrow.up")
            }
            .sheet(isPresented: $isSharing) {
                ShareSheet(
                    activityItems: activityItems(), // ["Place Holder" as Any],
                    excludedActivityTypes: [])
            }
            Button {
                Task {
                    // var newItem = item;
                    item.isFavorite = !item.isFavorite
                    self.app.galleryModel.updateMedia(media: item)
                }
            } label: {
                Label("Favorite", systemImage: item.isFavorite ? "heart.fill" : "heart")
            }
            // MediaDetailView topButtons Move Photo
            NavigationLink {
                GalleryPickerView(galleryKeys: app.galleryKeysExcludingCurrent,
                                  selection: $selection,
                                  mediaItem: item,
                                  mode: "Move to")
            } label: {
                Label("Move Photo", systemImage: "minus.square.fill")
            }
            // MediaDetailView topButtons Add Photo
            NavigationLink {
                GalleryPickerView(galleryKeys: app.galleryKeysExcludingCurrent,
                                  selection: $selection,
                                  mediaItem: item,
                                  mode: "Copy to")
            } label: {
                Label("Add Photo", systemImage: "plus.app.fill")
            }
        }
    }
    
    func imageFor(string str: String) async -> UIImage? {
        guard let url = URL(string: str) else { return nil }
        guard let (data, _) = try? await URLSession.shared.data(from: url) else { return nil }
        return UIImage(data:data)
    }
    
    func activityItems() -> [Any] {
        var items: [String] = []
        items.append("authorEmail: "+item.authorEmail)
        items.append("createdDate: "+item.createdDate)
        items.append("uid: "+item.uid)
        items.append("mediaPath: "+item.mediaPath)
        if !item.mediaPathFullRez.isEmpty {
            items.append("mediaPathFullRez: "+item.mediaPathFullRez)
        }
        if !item.previewUrl.isEmpty {
            items.append("previewUrl: "+item.previewUrl)
            items.append("loadPreviewUrl: "+String(item.loadPreviewUrl))
        }
        if !item.caption.isEmpty {
            items.append("caption: "+item.caption)
        }
        if let fullRezHeight = item.info["fullRezHeight"] as? Int {
            items.append("info.fullRezHeight: "+String(fullRezHeight))
        }
        if let fullRezWidth = item.info["fullRezWidth"] as? Int {
            items.append("info.fullRezWidth: "+String(fullRezWidth))
        }
        if let imageWidth = item.info["imageWidth"] as? Int {
            items.append("info.imageWidth: "+String(imageWidth))
        }
        if let imageHeight = item.info["imageHeight"] as? Int {
            items.append("info.imageHeight: "+String(imageHeight))
        }
        if let lat = item.info["lat"] as? Double {
            items.append("info.lat: "+String(lat))
        }
        if let lon = item.info["lon"] as? Double {
            items.append("info.lon: "+String(lon))
        }
        if let sourceDate = item.info["sourceDate"] as? String {
            items.append("info.sourceDate: "+sourceDate)
        }
        if let sourceId = item.info["sourceId"] as? String {
            items.append("info.sourceId: "+sourceId)
        }
        if let mediaType = item.info["mediaType"] as? String {
            items.append("info.mediaType: "+mediaType)
        }
        let str = items.joined(separator: "\n")
        return [self.imageThumb as Any, str];
    }
}

//    struct EditButtons: View {
//        @Binding var showingAlert: Bool;
//        @Binding var selection: String?
//        var item: MediaModel
//
//        @EnvironmentObject var app: AppModel
//
//        var body: some View {
//            HStack(spacing: 60) {
//                Button {
//                    showingAlert = true
//                } label: {
//                    Label("Delete", systemImage: "trash")
//                        .font(.system(size: 24))
//                }
//                // MediaDetailView EditButtons Add Photo
//                NavigationLink {
//                    GalleryPickerView(galleryKeys: app.galleryKeysExcludingCurrent,
//                                      selection: $selection,
//                                      mediaItem: item)
//                } label: {
//                    Label("Add Photo", systemImage: "plus.app.fill")
//                        .font(.system(size: 24))
//                }
//            }
//            .buttonStyle(.plain)
//            .labelStyle(.iconOnly)
//            .padding(EdgeInsets(top: 20, leading: 30, bottom: 20, trailing: 30))
//            .background(Color.secondary.colorInvert())
//            .cornerRadius(15)
//        }
//    }

//                        NavigationLink {
//                            MapView(locs: lobbyModel.mapRegion.locs)
//                        } label: {
//                            Text(locationDescription)
//                        }


// https://www.hackingwithswift.com/books/ios-swiftui/sending-and-receiving-codable-data-with-urlsession-and-swiftui

// var changed = false
// if let priorCaption, priorCaption != item.caption {
//  changed = true
// }
// if let priorPreviewUrl, priorPreviewUrl != item.previewUrl {
// changed = true
// }
// if let priorLoadPreviewUrl, priorLoadPreviewUrl != item.loadPreviewUrl {
// changed = true
// }
// if changed {
//  Task {
//      app.galleryModel.updateMedia(media: item)
// }
// }

//  Button("Save") {
//      app.galleryModel.updateMedia(media: item)
//      dismiss()
//  }
