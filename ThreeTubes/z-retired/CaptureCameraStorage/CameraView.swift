/*
See the License.txt file for this sample’s licensing information.
*/

// !!@ NavigationStack requires ios 16.0 - is it needed?

import SwiftUI

import FirebaseAuth
import FirebaseStorage

struct CameraView: View {
    @EnvironmentObject private var photosModel:PhotosModel
    @EnvironmentObject var lobbyModel: LobbyModel

    private static let barHeightFactor = 0.15
    
    @State private var authenticated: Bool = true

    var body: some View {
        
        NavigationStack {
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
            .task {
                await photosModel.camera.start()
                await photosModel.loadPhotos()
                await photosModel.loadThumbnail()
                
                // await signInAnonymously()
            }
            .navigationTitle("Camera")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .ignoresSafeArea()
            .statusBar(hidden: true)
        }
        .onAppear {
            print("onAppear CameraView")
        }
        .onDisappear {
            print("onDisappear CameraView")
        }
    }
    
    private func buttonsView() -> some View {
        HStack(spacing: 30) {
            
            Spacer()
            
            NavigationLink {
                GalleryView()
            } label: {
                Label("Media Gallery", systemImage: "photo.stack.fill")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
            }

            NavigationLink {
                if Auth.auth().currentUser == nil {
                    LoginView()
                        .onAppear {
                          // lobbyModel.uploadCount = 0;
                        }
                }
                else {
                    LobbyView()
                }
            } label: {
                Label("Home", systemImage: "person.3.fill")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.white)
            }

            NavigationLink {
                PhotoCollectionView(photoCollection: photosModel.photoCollection)
                    .onAppear {
                        photosModel.camera.isPreviewPaused = true
                    }
                    .onDisappear {
                        photosModel.camera.isPreviewPaused = false
                    }
            } label: {
                Label {
                    Text("Album")
                } icon: {
                    ThumbnailView(image: photosModel.thumbnailImage)
                }
            }
            
            Button {
                photosModel.camera.takePhoto()
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
                photosModel.camera.switchCaptureDevice()
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
    }
    
    func signInAnonymously() async {
        // Using Cloud Storage for Firebase requires the user be authenticated. Here we are using
        // anonymous authentication.
        print("signInAnonymously", Auth.auth().currentUser ?? "no-user")
        print("uid", Auth.auth().currentUser?.uid ?? "")
        if Auth.auth().currentUser == nil {
            do {
                try await Auth.auth().signInAnonymously()
                authenticated = true
            } catch {
                print("Not able to connect: \(error)")
//                Task { @MainActor in
//                    usersModel.errorFound = true
//                    usersModel.errInfo = error
//                }
                authenticated = false
            }
        }
    }

}
