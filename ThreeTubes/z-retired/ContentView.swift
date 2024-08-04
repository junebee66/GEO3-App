//
//  ContentView.swift
//  Ellifit
//
//  Created by Rudrank Riyam on 02/05/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var lobbyModel: LobbyModel
    
    var body: some View {
        switch lobbyModel.state {
        case .signedIn: LobbyView()
        case .signedOut: LoginView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
