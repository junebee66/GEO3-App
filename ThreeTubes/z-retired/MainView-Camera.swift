/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

struct MainView: View {
    
    @StateObject var photosModel: PhotosModel
    @StateObject var lobbyModel: LobbyModel
    @StateObject var cameraModel: CameraModel
    
    @EnvironmentObject var app: AppModel

    private static let barHeightFactor = 0.15
    
    @State private var authenticated: Bool = true

    var body: some View {
        
        NavigationStack(path: $app.path) {
            GeometryReader { geometry in
                ViewfinderView(image:  $photosModel.viewfinderImage )
                    .overlay(alignment: .top) {
                        Color.black
                            .opacity(0.75)
                            .frame(height: geometry.size.height * Self.barHeightFactor)
                    }
                    .overlay(alignment: .bottom) {
                        buttonsView()
                            .frame(height: geometry.size.height * Self.barHeightFactor)
                            .background(.black.opacity(0.75))
                    }
                    .overlay(alignment: .center)  {
                        Color.clear
                            .frame(height: geometry.size.height * (1 - (Self.barHeightFactor * 2)))
                            .accessibilityElement()
                            .accessibilityLabel("View Finder")
                            .accessibilityAddTraits([.isImage])
                    }
                    .background(.black)
            }
            .navigationTitle("MoGallery")
            .navigationBarTitleDisplayMode(.inline)
            // .navigationBarHidden(true)
            .ignoresSafeArea()
            .statusBar(hidden: true)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    NavigationLink {
                        if lobbyModel.currentUser == nil {
                            LoginView(lobbyModel: lobbyModel)
                        }
                        else {
                            LobbyView(lobbyModel: lobbyModel)
                        }
                    } label: {
                        Label("Lobby", systemImage: "info.circle")
                            // .font(.system(size: 30, weight: .bold))
                            // .foregroundColor(.white)
                            // .foregroundColor(.black)
                    }
                }
            }

        }
        .onAppear {
            print("MainView onAppear currentUser", lobbyModel.currentUser?.email ?? "-none-")
        }
    }
    
    private func buttonsView() -> some View {
        HStack(spacing: 30) {
            
            Spacer()
            
            NavigationLink(value: "gallery") {
                Label("Media Gallery", systemImage: "photo.stack.fill")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
            }
            
            NavigationLink(value: "photoCollection") {
                Label {
                    Text("Album")
                } icon: {
                    ThumbnailView(image: photosModel.thumbnailImage)
                }
            }
                        
            Button {
                cameraModel.takePhoto()
            } label: {
                Label {
                    Text("Take Photo")
                } icon: {
                    ZStack {
                        Circle()
                            .strokeBorder(.white, lineWidth: 3)
                            .frame(width: 62, height: 62)
                        Circle()
                            .fill(.white)
                            .frame(width: 50, height: 50)
                    }
                }
            }
            
            Button {
                cameraModel.switchCaptureDevice()
            } label: {
                Label("Switch Camera", systemImage: "arrow.triangle.2.circlepath")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
        .padding()
        .navigationDestination(for: String.self) { dest in
            if dest == "gallery" {
                GalleryView(galleryModel: app.galleryModel)
            }
            else {
                PhotoCollectionView(photosModel: photosModel, albumName: lobbyModel.albumName )
                    .onAppear {
                        cameraModel.isPreviewPaused = true
                    }
                    .onDisappear {
                        cameraModel.isPreviewPaused = false
                    }
            }
        }
    }
    
//    func signInAnonymously() async {
//        // Using Cloud Storage for Firebase requires the user be authenticated. Here we are using
//        // anonymous authentication.
//        print("signInAnonymously", Auth.auth().currentUser ?? "no-user")
//        print("uid", Auth.auth().currentUser?.uid ?? "")
//        if Auth.auth().currentUser == nil {
//            do {
//                try await Auth.auth().signInAnonymously()
//                authenticated = true
//            } catch {
//                print("Not able to connect: \(error)")
//                authenticated = false
//            }
//        }
//    }

}
