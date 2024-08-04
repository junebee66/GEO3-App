//
// LobbyView
// display list of users that have logged in

import SwiftUI

// https://www.hackingwithswift.com/quick-start/swiftui/how-to-load-a-remote-image-from-a-url
// Use AsyncImage in place of NetworkImage to avoid async warning

struct LobbyView: View {

    @EnvironmentObject var lobbyModel: LobbyModel
    @EnvironmentObject var app: AppModel
    
    var body: some View {
        NavigationStack {
            VStack {
                userHeaderView()
                if app.settings.showUsers {
                    userListView()
                }
                // !!@ if ! or else causes jump back to Camera view
                if !app.settings.showUsers {
                    AppSettingView()
                }
            }
            .navigationTitle("Info MoGallery v\(app.verNum)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        app.settings.showUsers.toggle()
                        app.saveSettings();
                    }) {
                        Image(systemName: app.settings.showUsers ?
                              "person.3.sequence.fill" : "person.3.sequence")
                    }
                }
            }
        }
        .onAppear {
            print("LobbyView onAppear")
            app.lobbyModel.locsForUsers(firstLoc: nil)
        }
    }
    
    private func userHeaderView() -> some View {
        VStack {
            userDetailRow()
            Button(action: lobbyModel.signOut) {
                Text("Sign Out")
                    .foregroundColor(.white)
                    .padding()
                    // .frame(maxWidth: .infinity)
                    .background(Color(.systemIndigo))
                    .cornerRadius(12)
                    .padding(5)
            }
        }
    }
    
    private func userDetailRow() -> some View {
        HStack {
            if let currentUser = lobbyModel.currentUser {
                NavigationLink {
                    UserDetailView(user: currentUser )
                } label: {
                    VStack(alignment: .leading) {
                        Text(currentUser.name)
                            .font(.headline)
                        Text(currentUser.email)
                            .font(.subheadline)
                         Text(currentUser.caption)
                            .lineLimit(1)
                          .font(.subheadline)
                    }
                }
            }
            Spacer()
        }
        .padding()
        // .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
    }
    
    private func userListView() -> some View {
        List {
            Text("\(lobbyModel.users.count) users")
            // .frame(alignment: .leading)
            // .multilineTextAlignment(.trailing)
            ForEach(lobbyModel.users) { user in
                NavigationLink {
                    UserDetailView(user: user )
                } label: {
                    userRowView(user: user)
                }
            }
        }
    }
    
    private func userRowView(user: UserModel) -> some View {
        HStack {
            AsyncImage(url: URL(string: user.profileImg))
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80, alignment: .center)
            VStack(alignment: .leading) {
                Text(user.name)
                    .font(.headline)
                Text(user.email)
                    .font(.subheadline)
                HStack {
                    Text(user.dateIn.getElapsedInterval())
                        .font(.subheadline)
                    Spacer()
                    Text(user.activeCountLabel ?? "")
                        .font(.subheadline)
                }
                Text(user.caption)
                    .font(.subheadline)
                    .lineLimit(1)
            }
            Spacer()
        }
//        .onTapGesture {
//            print("userListView onTapGesture user", user)
//            app.setStoreGallery(key: user.userGalleryKey)
//            app.toGalleryTab()
//        }
    }
}

struct LocationRow: View {
    var user: UserModel
    
    @EnvironmentObject var lobbyModel: LobbyModel
    @EnvironmentObject var app: AppModel
    
    var body: some View {
        if let locationDescription = user.locationDescription {
            Text(locationDescription)
        }
    }
}

//            NavigationLink {
//                MapView()
//                 MapView(mapRegion: lobbyModel.mapRegion)
//                MapView(lobbyModel: lobbyModel)
//                MapView(locs: lobbyModel.mapRegion.locs)
//            } label: {

// .cornerRadius(8)
// .onTapGesture {
//      print("userListView AsyncImage onTapGesture user", user)
//      app.setStoreGallery(key: user.userGalleryKey)
//      app.selectedTab = .gallery
//  }
