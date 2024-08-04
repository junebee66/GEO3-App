//
//  MediaModel.swift
//  CaptureCameraStorage
//
//  Created by jht2 on 12/20/22.
//

import Foundation

class MediaModel: ObservableObject, Identifiable {
    
    @Published var id: String
    @Published var uid: String
    @Published var authorEmail: String
    @Published var mediaPath: String
    @Published var uploadCount: Int
    @Published var createdAt: Date

    init(id: String) {
        self.id = id;
        self.uid = ""
        self.authorEmail = ""
        self.mediaPath = ""
        self.uploadCount = 0
        self.createdAt  = Date(timeIntervalSinceReferenceDate: 0.0);
    }
    
    init?(id: String, dict: [String: Any]) {
        let uid = dict["uid"] as? String ?? ""
        let authorEmail = dict["authorEmail"] as? String ?? ""
        let mediaPath = dict["mediaPath"] as? String ?? ""
        let uploadCount = dict["uploadCount"] as? Int ?? 0
        let createdAt = dict["createdAt"] as? TimeInterval ?? 0

        self.id = id
        self.uid = uid
        self.authorEmail = authorEmail
        self.mediaPath = mediaPath
        self.uploadCount = uploadCount
        self.createdAt = Date(timeIntervalSinceReferenceDate: createdAt);
    }
}
