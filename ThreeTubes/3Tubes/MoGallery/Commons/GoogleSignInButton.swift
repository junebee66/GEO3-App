//
//  GoogleSignInButton.swift
//  Ellifit
//
//  Created by Rudrank Riyam on 21/12/21.
//

import SwiftUI
import GoogleSignIn

struct GoogleSignInButton: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme
    
    private var button = GIDSignInButton()
    
    func makeUIView(context: Context) -> GIDSignInButton {
        button.colorScheme = colorScheme == .dark ? .dark : .light
        print("GoogleSignInButton button.frame", button.frame)
        // var frame = button.frame
        // button.frame = CGRect(x:frame.minX,y:frame.minY,width: frame.width,height: frame.height)
        return button
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        button.colorScheme = colorScheme == .dark ? .dark : .light
    }
}
