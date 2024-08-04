//
//  LoginView.swift

import SwiftUI

// ?? Why not centered vertically with Spacers

struct LoginView: View {
    
    @EnvironmentObject var lobbyModel: LobbyModel

    @EnvironmentObject var app: AppModel
    @Environment(\.openURL) var openURL

    var body: some View {
        NavigationStack {
            VStack {
                Text("MoLobby")
                    .font(.system(size: 50, weight: .bold))
                // Spacer()

                Text("""
Welcome to MoLobby version \(app.verNum)
""")
                // Button move from bottom to avoid getting overlaid with links
                // and rendered inaccessible
                
                GoogleSignInButton()
                    .padding()
                    .onTapGesture {
                        lobbyModel.signIn()
                    }

                Text("""
Hello!
""")
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(2)
                
//                Link("Video overview youtube.com",
//                     destination:
//                        URL(string: "https://jht1493.net/MoGallery/VideoOverView")! )
//                .padding(14)
//                Link("MoGallery github.com",
//                     destination:
//                        URL(string: "https://github.com/mobilelabclass-itp/98-MoGallery")! )
//                .padding(14)
                
            }
        }
        .onAppear {
            print("LoginView onAppear currentUser", lobbyModel.currentUser?.email ?? "-none-")
        }
        .onDisappear {
            print("LoginView onDisappear")
            app.locationManager.requestUse();
        }
    }
}

//struct LoginView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginView()
//    }
//}
