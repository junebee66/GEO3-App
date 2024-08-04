//
//  MediaModel.swift
//  CaptureCameraStorage
//
//  Created by jht2 on 12/20/22.
//

import Foundation
import MapKit
import SwiftUI

struct MediaModel: Codable, Equatable, Identifiable {
    
    static func == (lhs: MediaModel, rhs: MediaModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case uid
        case authorEmail
        case mediaPath
        case storagePath
        case uploadCount
        case createdAt
        case info
        case homeRef
        case mediaPathFullRez
        case storagePathFullRez
        case createdDate
        case userGalleryChildId
    }

    var id: String
    var uid: String
    var authorEmail: String
    var mediaPath: String
    var storagePath: String
    var uploadCount: Int
    var createdAt: Date
    var info: [String: Any]
    var homeRef: [String]
    var mediaPathFullRez: String
    var storagePathFullRez: String
    var createdDate: String
    var userGalleryChildId: String
    
    var homeRefLabel: String {
        homeRef.isEmpty ? "": "[\( homeRef[0] )]"
    }
    
    var fullRezWidth: Int {
        info["fullRezWidth"] as? Int ?? -1
    }
    
    var fullRezHeight:Int {
        info["fullRezHeight"] as? Int ?? -1
    }

    var mediaPathDetail: String {
        if !mediaPathFullRez.isEmpty { return mediaPathFullRez }
        return mediaPath
    }

    var width:Int {
        let val = fullRezWidth
        if val > 0 { return val }
        return info["imageWidth"] as? Int ?? -1
    }
    
    var height:Int {
        let val = fullRezHeight
        if val > 0 { return val }
        return info["imageHeight"] as? Int ?? -1
    }

    var sourceDate: String? {
        guard let item = info["sourceDate"] else { return nil }
        return item as? String
    }
    
    var sourceId: String? {
        guard let item = info["sourceId"] else { return nil }
        return item as? String
    }

    // init? if we want to allow for invalid entries filter out with compactMap
    // init?(id: String, dict: [String: Any]) {
    init(id: String, dict: [String: Any]) {
        let uid = dict["uid"] as? String ?? ""
        let authorEmail = dict["authorEmail"] as? String ?? ""
        let mediaPath = dict["mediaPath"] as? String ?? ""
        let storagePath = dict["storagePath"] as? String ?? ""
        let uploadCount = dict["uploadCount"] as? Int ?? 0
        let createdAt = dict["createdAt"] as? TimeInterval ?? 0
        let info = dict["info"] as? [String: Any] ?? [:]
        let homeRef = dict["homeRef"] as? [String] ?? []
        let mediaPathFullRez = dict["mediaPathFullRez"] as? String ?? ""
        let storagePathFullRez = dict["storagePathFullRez"] as? String ?? ""
        let createdDate = dict["createdDate"] as? String ?? ""
        let userGalleryChildId = dict["userGalleryChildId"] as? String ?? ""
        
        self.id = id
        self.uid = uid
        self.authorEmail = authorEmail
        self.mediaPath = mediaPath
        self.storagePath = storagePath
        self.uploadCount = uploadCount
        self.createdAt = Date(timeIntervalSinceReferenceDate: createdAt);
        self.info = info
        self.homeRef = homeRef
        self.mediaPathFullRez = mediaPathFullRez
        self.storagePathFullRez = storagePathFullRez
        self.createdDate = createdDate
        self.userGalleryChildId = userGalleryChildId
    }
}


extension MediaModel {
    var locationDescription: String? {
        guard let lat = info["lat"] as? Double else { return nil }
        guard let lon = info["lon"] as? Double else { return nil }
        return "\( String(format: "%.6f", lat) ) \( String(format: "%.6f", lon) )"
    }
    var loc: Location? {
        guard let lat = info["lat"] as? Double else { return nil }
        guard let lon = info["lon"] as? Double else { return nil }
        return Location(id: "photo:", latitude: lat, longitude: lon, label: "photo")
    }
}
