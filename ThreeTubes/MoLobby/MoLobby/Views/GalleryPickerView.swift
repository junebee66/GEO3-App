//
//  GalleryViewDetail.swift
//  MoGallery
//
//  Created by jht2 on 1/8/23.
//

import SwiftUI

struct GalleryPickerView: View {
    @State var galleryKeys: [String]
    @Binding var selection: String?
    var mediaItem: MediaModel?
    var mode = "Select"
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var app: AppModel
    
    @State var newGallery = ""
    @Environment(\.editMode) private var editMode
    @State var showAll = false
    @State var galleryKeysSettings: [String] = []
    
    var body: some View {
        Group {
            VStack {
                List {
                    ForEach(galleryKeys, id: \.self) { item in
                        Text(app.displayTitle(galleryName: item) )
                            .font(.title)
                            .frame(width: 400, height: 40)
                            .background( item == selection ?
                                         Color(uiColor:UIColor.tintColor)
                                         : Color(uiColor:UIColor.systemFill))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selection = item
                            }
                    }
                    .onDelete { (indices) in
                        print("onDelete", indices)
                        app.removeGalleryKey(at: indices)
                        app.saveSettings()
                        galleryKeys = app.settings.galleryKeys
                        // selection = nil
                    }
                }
                if !showAll {
                    HStack {
                        TextField("new", text: $newGallery)
                            .autocapitalization(.none)
                            .padding(.all)
                            .border(Color(UIColor.separator))
                            .padding(.all)
                        Button(action: {
                            var name = newGallery;
                            if newGallery.isEmpty {
                                name = String(app.settings.galleryKeys.count + 1)
                            }
                            name = "gallery-" + name
                            // name = app.settings.storePrefix + "gallery-" + name
                            // name = "mo-gallery-" + name
                            app.addGalleryKey(name: name)
                            // app.saveSettings()
                            selection = name
                        }) {
                            Text("Add")
                        }
                        .padding()
                    }
                }
            }
            .onChange(of: selection) { newState in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismissPicker()
                }
            }
        }
        // .navigationBarItems(trailing: EditButton())
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    print("Show All action")
                    if !showAll {
                        galleryKeysSettings = galleryKeys
                        galleryKeys = app.metaModel.allGalleryKeys()
                    }
                    else {
                        galleryKeys = galleryKeysSettings
                    }
                    showAll.toggle()
                    if showAll {
                        editMode?.wrappedValue = .inactive
                    }
                }) {
                    Text(showAll ? "Less" : "More")
                }
                if !showAll && mediaItem == nil {
                    EditButton()
                }
            }
        }
        .navigationTitle( mode )
        .navigationBarTitleDisplayMode(.inline)
        // .onDisappear {
        //  print("GalleryPickerView onDisappear")
        // }
    }
    
    // GalleryPickerView dismissPicker
    private func dismissPicker() {
        print("GalleryPickerView selection", selection ?? "-none-")
        print("GalleryPickerView mediaItem", mediaItem ?? "-none-")
        print("GalleryPickerView storeGalleryKey", app.settings.storeGalleryKey )
        if let selection {
            if let mediaItem, selection != app.settings.storeGalleryKey {
                if mode == "Move to" {
                    app.galleryModel.moveMediaEntry(galleryKey: selection, mediaItem: mediaItem)
                }
                else {
                    app.galleryModel.createMediaEntry(galleryKey: selection, mediaItem: mediaItem)
                }
            }
            // app.addGalleryKey(name: selection)
            app.setStoreGallery(key: selection)
        }
        dismiss()
    }
    
}

//struct GalleryViewDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        GalleryViewDetail()
//    }
//}

// Support dark mode hilight of selection
// https://developer.apple.com/documentation/uikit/uicolor/ui_element_colors
//    .background( item == selection ?
//                 Color(uiColor:UIColor.tintColor)
//                 : Color(uiColor:UIColor.systemFill))
