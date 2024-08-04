//
//  Settings.swift
//  MoGallery
//
//  Created by jht2 on 3/11/23.
//

import Foundation

struct Settings: Codable {
    
    var photoAlbum = "-Photo Library-"
    var photoSize = "" // Size is empty string for default full resolution
    var photoAddEnabled = false;
    
    var storePhotoSize = "500"
    var storeAddEnabled = true;
    var storeFullRez = true;
    var storePrefix = "mo-1/";
    var storeGalleryKey = "gallery-1"
    var storeLobbyKey = "lobby-@r-"

    var showUsers = false
    var randomAddWarning = true
    
    var galleryKeys:[String] = ["gallery-1", "gallery-2", "gallery-3"]
    // var galleryKeys:[String] = ["mo-gallery-1", "mo-gallery-2", "mo-gallery-3"]

    var hardGalleryDelete = false

}
