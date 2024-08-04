//
//  UserDetailView.swift
//  MoGallery
//
//  Created by jht2 on 2023-02-09
//

import SwiftUI

struct MetaDetailView: View {
    
    @ObservedObject var metaEntry: MetaEntry

    @EnvironmentObject var metaModel: MetaModel
    @EnvironmentObject var app: AppModel

    var body: some View {
        VStack() {
            Text(metaEntry.galleryName )
                .font(.headline)
        }
        Form {
            Section {
                Text("Caption")
                TextField("", text: $metaEntry.caption, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
            }
        }
        .onDisappear {
            print("MetaDetailView onDisappear")
            metaModel.update(metaEntry: metaEntry);
        }
    }
}

//struct AppSettingView_Previews: PreviewProvider {
//    static var previews: some View {
//        AppSettingView( )
//            .environmentObject(AppModel())
//    }
//}
