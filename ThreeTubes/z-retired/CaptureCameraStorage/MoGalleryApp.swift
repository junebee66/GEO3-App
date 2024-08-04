/*
 See the License.txt file for this sample’s licensing information.
 */

import SwiftUI
import Firebase
import GoogleSignIn

let gLobbyModel = LobbyModel();
let gGalleryModel = GalleryModel();

@main
struct MoGalleryApp: App {
    @StateObject var lobbyModel = gLobbyModel;
    @StateObject var photosModel = PhotosModel(gLobbyModel)

    init() {
        UINavigationBar.applyCustomAppearance()
        FirebaseApp.configure()
        gLobbyModel.observeUsersStart();
        gGalleryModel.observeMediaStart();
    }
    
    var body: some Scene {
        WindowGroup {
            CameraView()
            // ContentView()
                .environmentObject(lobbyModel)
                .environmentObject(photosModel)
                .onAppear {
                    lobbyModel.signIn()
                }
        }
    }
}

fileprivate extension UINavigationBar {
    
    static func applyCustomAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
