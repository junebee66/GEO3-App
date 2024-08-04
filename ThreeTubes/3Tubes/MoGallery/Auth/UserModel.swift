//
//  UserViewModel.swift
//  MoGallery
//
//  Created by jht2 on 12/19/22.
//

import Foundation
import MapKit

class UserModel: ObservableObject, Identifiable {
    
    var id: String
    var name: String
    var email: String
    var profileImg: String
    var dateIn: Date
    var uploadCount: Int
    var activeCount: Int
    var stats: [String:Any];
    @Published var caption: String

    // @Published var activeLapse: TimeInterval
    var info:[String: Any] = [:]
    
    var activeCountLabel: String? {
        if activeCount > 0 { return "signin: "+String(activeCount) }
        return nil
    }
    
    var userGalleryKey: String {
        let nemail = email.replacingOccurrences(of: ".", with: "-")
        let str = "zu-\( id )-\( nemail )"
        // print("userGalleryKey", str)
        return str
    }
    
    init(id: String, dict: [String: Any]) {
        let name = dict["name"] as? String ?? ""
        let email = dict["email"] as? String ?? ""
        let profileImg = dict["profileImg"] as? String ?? ""
        let dateIn = dict["dateIn"] as? TimeInterval ?? 0
        let uploadCount = dict["uploadCount"] as? Int ?? 0
        let activeCount = dict["activeCount"] as? Int ?? 0
        let caption = dict["caption"] as? String ?? ""
        let stats = dict["stats"] as? [String:Any] ?? [String:Any]()
        
        self.id = id
        self.name = name;
        self.email = email
        self.profileImg = profileImg
        self.dateIn = Date(timeIntervalSinceReferenceDate: dateIn);
        self.uploadCount = uploadCount
        self.activeCount = activeCount
        self.caption = caption
        self.stats = stats
        
        self.info = dict
        // info["lat
        // info["lon
    }
}

extension UserModel {
    var locationDescription: String? {
        guard let lat = info["lat"] as? Double else { return nil }
        guard let lon = info["lon"] as? Double else { return nil }
        return "\( String(format: "%.6f", lat) ) \( String(format: "%.6f", lon) )"
    }
    var loc: Location? {
        guard let lat = info["lat"] as? Double else { return nil }
        guard let lon = info["lon"] as? Double else { return nil }
        return Location(id: email, latitude: lat, longitude: lon, label: email)
    }
}
