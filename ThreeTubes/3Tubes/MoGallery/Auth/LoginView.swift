import SwiftUI
import UIKit
import AVFoundation
import AVKit


//func imageFor(_ str: String) -> UIImage {
//    let url = URL(string: str)
//    let imgData = try? Data(contentsOf: url!)
//    let uiImage = UIImage(data:imgData!)
//    return uiImage!
//}
//
//// profile image
//let u1 = "https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExNnhpYnE2eHNrdWwweDUydzAza3VwcXVteDAyaXFuN205Zmp2NDV4biZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9cw/vilrxqdiL82Qyxyh3f/giphy.gif"
//let ui1 = imageFor(u1)
//
//// itp staff
//let u2 = "https://tisch.nyu.edu/content/dam/tisch/itp/Faculty/dan-osullivan1.jpg.preset.square.jpeg"
//let ui2 = imageFor(u2)
//
//let sz = CGSize(width: 200, height: 200)
//let renderer = UIGraphicsImageRenderer(size: sz)
//
//let image = renderer.image { (context) in
//    ui1.draw(in: CGRect(x: 0, y: 0, width: 100, height: 100))
//    ui2.draw(in: CGRect(x: 100, y: 0, width: 100, height: 100))
//
//}
//
//
struct PlayerView: UIViewRepresentable {
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
    }

    func makeUIView(context: Context) -> UIView {
        return PlayerUIView(frame: .zero)
    }
    
}

class PlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let url = URL(string: "https://cdn.dribbble.com/uploads/48226/original/b8bd4e4273cceae2889d9d259b04f732.mp4?1689028949")!
        let player = AVPlayer(url: url)
        player.actionAtItemEnd = .none
        player.play()
        
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)

        layer.addSublayer(playerLayer)
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        if let playerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: .zero, completionHandler: nil)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}




struct LoginView: View {
    @EnvironmentObject var lobbyModel: LobbyModel
    @EnvironmentObject var app: AppModel
    @Environment(\.openURL) var openURL


    var body: some View {
        ZStack {
            // Login content
            
//            Image(uiImage: ui1)
//                .resizable()
////                    .scaledToFill()
////                    .edgesIgnoringSafeArea(.all)
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
            PlayerView()
                                .edgesIgnoringSafeArea(.all)
//            NavigationStack {
                VStack {
                        Spacer()
                        Text("3Tubes")
                            .font(.system(size: 50, weight: .bold))
                        Text("""
                            Welcome to 3Tubes version \(app.verNum)
                            """)

                        // ... Rest of your content ...

                    HStack{
                        Spacer()
                        GoogleSignInButton()
                            .onTapGesture {
                                lobbyModel.signIn()
                            }
                        Spacer()
                    }

//                        Text("""
//                            Please give permission to access your entire Photo Library. This does not automatically make your entire library visible to other users of the app. You have to specifically add items to galleries from your Photo Library or Camera to make them visible to other users.
//
//                            All users are by invitation of the developer only and are visible to each other.
//
//                            Experimental alpha software - use at your own risk. You can always delete shared items if you change your mind.
//
//                            Don't worry, be sharing happy!
//                            """)
//                            .fixedSize(horizontal: false, vertical: true)
//                            .padding(2)
                    }
                }
//                .onAppear {
//                    print("LoginView onAppear currentUser", lobbyModel.currentUser?.email ?? "-none-")
//                }
//                .onDisappear {
//                    print("LoginView onDisappear")
//                    app.locationManager.requestUse()
//                }
//        }
    }
}
