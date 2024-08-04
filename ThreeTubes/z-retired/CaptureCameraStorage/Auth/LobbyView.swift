//
//  HomeView.swift
//  Ellifit
//
//  Created by Rudrank Riyam on 05/05/21.
//

// https://www.hackingwithswift.com/quick-start/swiftui/how-to-load-a-remote-image-from-a-url
// Use AsyncImage in place of NetworkImage to avoid async warning

import SwiftUI
import GoogleSignIn
import FirebaseAuth

struct LobbyView: View {

    @EnvironmentObject var lobbyModel: LobbyModel
//    private let user = GIDSignIn.sharedInstance.currentUser
//    private let auid = Auth.auth().currentUser?.uid;
    
    var body: some View {
        //    NavigationView {
        VStack {
            HStack {
                if let currentUser = lobbyModel.currentUser {
                    // AsyncImage(url: user?.profile?.imageURL(withDimension: 80))
                    AsyncImage(url: URL(string: currentUser.profileImg))
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80, alignment: .center)
                    VStack(alignment: .leading) {
                        Text(currentUser.name )
                            .font(.headline)
                        Text(currentUser.email )
                            .font(.subheadline)
                        Text(currentUser.id )
                            .font(.subheadline)
                    }
                }
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .padding()
            
            Spacer()
            List {
                ForEach(lobbyModel.users) { user in
                    HStack {
                        // NetworkImage(url: user?.profile?.imageURL(withDimension: 200))
                        AsyncImage(url: URL(string: user.profileImg))
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80, alignment: .center)
                        // .cornerRadius(8)
                        VStack(alignment: .leading) {
                            Text(user.name)
                                .font(.headline)
                            Text(user.email)
                                .font(.subheadline)
                            Text(user.dateIn.description)
                                .font(.subheadline)
                        }
                        Spacer()
                    }
                }
            }
            Spacer()
            
            Button(action: lobbyModel.signOut) {
                Text("Sign out")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemIndigo))
                    .cornerRadius(12)
                    .padding()
            }
        }
        .navigationTitle("Users")
        .navigationBarTitleDisplayMode(.inline)
//        .onAppear {
//            lobbyModel.observeUsersStart();
//        }
//        .onDisappear {
//            lobbyModel.observeUsersStop();
//        }
        //    }
        // .navigationViewStyle(StackNavigationViewStyle())
    }
}

// A generic view which is helpful for showing images from the network.
struct NetworkImage: View {
    let url: URL?
    
    var body: some View {
        if let url = url,
           let data = try? Data(contentsOf: url),
           let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        LobbyView()
    }
}
