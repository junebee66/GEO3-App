//
//  AppModel_gallery.swift
//  MoGallery
//
//  Created by jht2 on 8/19/23.
//

import SwiftUI

extension AppModel {
    func selectGallery(key: String) {
        setStoreGallery(key: key)
        toGalleryTab()
    }
    
    func toGalleryTab() {
        selectedTab = .gallery
        print("toGalleryTab galleryModel.path", galleryModel.path)
        while !galleryModel.path.isEmpty {
            galleryModel.path.removeLast()
        }
    }
    
    func removeGalleryKey(at offsets: IndexSet) {
        if settings.hardGalleryDelete {
            if let index = offsets.first {
                let name = settings.galleryKeys[index]
                metaModel.removeMeta(galleryName: name)
            }
        }
        settings.galleryKeys.remove(atOffsets: offsets)
    }
    
    // Add a gallery by name
    // If not already present, add and save settings
    func addGalleryKey(name: String) {
        let _ = metaModel.addMeta(galleryName: name)
        if !present(galleryName: name) {
            settings.galleryKeys.append(name);
            saveSettings()
        }
    }
    
    func present(galleryName: String) -> Bool {
        settings.galleryKeys.contains(galleryName)
    }
    
    var galleryKeysExcludingCurrent: [String] {
        let filter: (String) -> String? = { item in
            if item == self.settings.storeGalleryKey {
                return nil
            }
            return item
        }
        return settings.galleryKeys.compactMap( filter )
    }
    
    func setStoreGallery(key: String) {
        settings.storeGalleryKey = key
        saveSettings()
        galleryModel.refresh()
        lobbyModel.refresh()
    }
    
    var galleyTitle: String {
        displayTitle(galleryName: settings.storeGalleryKey)
    }
    
    func displayTitle(galleryName: String) -> String {
        var titl = galleryName
        // 12345678901234567890123456789012
        // zu-oVFxc052pOWF5qq560qMuBmEsbr2-jht1900@gmail-com
        if titl.hasPrefix("zu-") {
            titl = String(titl.dropFirst(32)).replacingOccurrences(of: "-", with: ".")
        }
        return titl
    }
    
    func homeRefLabel(item: MediaModel) -> String {
        var label = ""
        if !item.homeRef.isEmpty {
            label = "[\( displayTitle(galleryName: item.homeRef[0]) )]"
        }
        return label;
    }

}

