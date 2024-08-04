/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

enum TabTag {
    case gallery
    case photos
    case camera
    case map
    case settings
}

struct MainView: View {
    
    @EnvironmentObject var lobbyModel: LobbyModel
//    @EnvironmentObject var photosModel: PhotosModel
//    @EnvironmentObject var cameraModel: CameraModel
    
    @EnvironmentObject var app: AppModel
    
    var body: some View {
//        TabView(selection: $app.selectedTab) {
//            GalleryTabView()
//                .tabItem {
//                    Label("Gallery", systemImage: "rectangle.stack")
//                }
//                .tag(TabTag.gallery)
//            PhotoCollectionView()
//                .tabItem {
//                    Label("Photos", systemImage: "photo.on.rectangle")
//                }
//                .tag(TabTag.photos)
//            CameraView()
//                .tabItem {
//                    Label("Camera", systemImage: "camera.fill")
//                }
//                .tag(TabTag.camera)
//            MapTabView(locs: lobbyModel.mapRegion.locs)
//                .tabItem {
//                    Label("Map", systemImage: "globe")
//                }
//                .tag(TabTag.map)
            settingsView()
                .tabItem {
                    Label("Info", systemImage: "info.circle")
                }
//                .tag(TabTag.settings)
//        }
        .onAppear {
            print("MainView onAppear currentUser", lobbyModel.currentUser?.email ?? "-none-")
        }
    }

    func settingsView() -> some View {
        Group {
            if lobbyModel.currentUser == nil {
                LoginView()
            }
            else {
                LobbyView()
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

// navigation with app.path

// NavigationStack(path: $app.path) {

// NavigationLink(value: "gallery") {
//    Label("Media Gallery", systemImage: "photo.stack.fill")
//        .font(.system(size: 36, weight: .bold))
//        .foregroundColor(.white)
// }

//    .navigationDestination(for: String.self) { dest in
//        if dest == "gallery" {
//            GalleryView(galleryModel: app.galleryModel)
//        }
//        else {

