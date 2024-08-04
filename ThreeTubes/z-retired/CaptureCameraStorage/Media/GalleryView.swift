//
//  MediaCollectionView.swift
//  CaptureCameraStorage
//
//  Created by jht2 on 12/20/22.
//

import SwiftUI

struct GalleryView: View {
    
    @StateObject var galleryModel = gGalleryModel
    
//    @State var infoViewPresented = false;
    
    @Environment(\.displayScale) private var displayScale
    private static let itemSpacing = 6.0
    // private static let itemCornerRadius = 15.0
    private static let itemSize = CGSize(width: 90, height: 90)
    private var imageSize: CGSize {
        return CGSize(width: Self.itemSize.width * min(displayScale, 2),
                      height: Self.itemSize.height * min(displayScale, 2))
    }
    
    private let columns = [
        GridItem(.adaptive(minimum: itemSize.width, maximum: itemSize.height), spacing: itemSpacing)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: Self.itemSpacing) {
                ForEach(galleryModel.gallery) { item in
                    MediaItemView(item: item, itemSize: Self.itemSize)
                }
            }
            .padding([.vertical], Self.itemSpacing)
        }
        .navigationTitle( "Gallery" )
        .navigationBarTitleDisplayMode(.inline)
        .statusBar(hidden: false)
//        .onAppear {
//            galleryModel.observeMediaStart();
//        }
//        .onDisappear {
//            galleryModel.observeMediaStop();
//        }
        .toolbar {
//            ToolbarItemGroup(placement: .navigationBarLeading) {
//                Button(action: {
//                }) {
//                    HStack {
//                        Image(systemName: "chevron.left")
//                        Text("One")
//                    }
//                }
//            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                NavigationLink {
                    InfoView()
                } label: {
                    Image(systemName: "info.circle")
                }
//                Button(action: {
//                    infoViewPresented = true
//                }) {
//                    Image(systemName: "info.circle")
//                }
//                .sheet(isPresented: $infoViewPresented) {
//                    InfoView( isPresented: $infoViewPresented)
//                }
            }
        }
    }
}

struct InfoView: View {
    
    var body: some View {
        VStack {
            Spacer()
            Text("Info")
            Spacer()
        }
    }
}

struct InfoViewPresenting: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Button(action: {
                    isPresented = false
                }) {
                    Text("Doit")
                }
            }
            .padding(20)
            Spacer()
            Text("Info")
            Spacer()
        }
    }
}

struct MediaItemView: View {
    var item: MediaModel;
    var itemSize: CGSize
    
    var body: some View {
        AsyncImage(url: URL(string: item.mediaPath))
        { image in
            image.resizable()
                .scaledToFill()

        } placeholder: {
            ProgressView()
        }
        .aspectRatio(contentMode: .fit)
        .frame(width: itemSize.width, height: itemSize.height)
        .clipped()
    }
}

struct MediaCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        GalleryView()
    }
}
