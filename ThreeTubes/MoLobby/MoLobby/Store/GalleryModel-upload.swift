//
//  GalleryModel-upload.swift
//  MoGallery
//
//  Created by jht2 on 3/11/23.
//

import FirebaseDatabase
import FirebaseStorage
import Photos
import UIKit
import SwiftUI

extension GalleryModel {
    
    func uploadImageData(_ imageData: Data,
                         fullRezData: Data?,
                         info: [String: Any]) {
        
        guard let lobbyRef = app.lobbyModel.lobbyRef else { return }
        guard let user = app.lobbyModel.currentUser else {
            print("uploadImageData no currentUser");
            return
        }
        // upload filepath is userid/uploadCount.jpeg
        let uid = user.id
        
        // add 1 to user uploadCount
        var values:[String: Any] = [:];
        values["uploadCount"] = ServerValue.increment(1);
        lobbyRef.child(uid).updateChildValues(values) { error, ref in
            if let error = error {
                print("uploadImageData uploadCount error: \(error).")
            }
        }
        // !!@ May get out of sync with users logged in multiple times
        // !!@ Need to observe current user
        user.uploadCount += 1;
        
        // Create file metadata including the content type
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        metadata.cacheControl = "public,max-age=300"
        
        let filePathPre = "-mo/\(app.settings.storePrefix)/\(uid)/\(user.uploadCount)"
        let filePath = "\(filePathPre).jpeg"
        let storageRef = storage.reference(withPath: filePath)
        
        // fullRezData
        // + mediaPathFullRez
        // + storagePathFullRez
        let filePathFullRez = "/\(filePathPre)z.jpeg"
        
        storageRef.putData(imageData, metadata: metadata) { metadata, error in
            guard let metad = metadata else {
                print("uploadImageData no metadata")
                return
            }
            print("uploadImageData metad size", metad.size)
            // You can also access to download URL after upload.
            self.fetchDownloadURL(storageRef,
                                  storagePath: filePath,
                                  metadata: metadata,
                                  info: info,
                                  fullRezData: fullRezData,
                                  filePathFullRez: filePathFullRez)
        }
    }
    
    func fetchDownloadURL(_ storageRef: StorageReference,
                          storagePath: String,
                          metadata: StorageMetadata?,
                          info: [String: Any],
                          fullRezData: Data?,
                          filePathFullRez: String) {
        
        storageRef.downloadURL { url, error in
            guard let downloadURL = url else {
                print("fetchDownloadURL download URL error : \(error.debugDescription)")
                return
            }
            // print("fetchDownloadURL download url:\n \(downloadURL) ")
            
            var values: [String: Any] = [:];
            values["mediaPath"] = downloadURL.description;
            values["storagePath"] = storagePath;
            
            if let fullRezData {
                self.putFullRezData(metadata: metadata,
                                    info: info,
                                    values: values,
                                    fullRezData: fullRezData,
                                    filePathFullRez: filePathFullRez)
            }
            else {
                self.createMediaEntry(info: info,
                                      values: values,
                                      galleryRef: self.galleryRef,
                                      galleryKey: self.app.settings.storeGalleryKey,
                                      user: self.app.lobbyModel.currentUser);
            }
        }
    }
    
    func putFullRezData(metadata: StorageMetadata?,
                        info: [String: Any],
                        values: [String: Any] ,
                        fullRezData: Data,
                        filePathFullRez: String) {
        
        let storageRefFullRez = storage.reference(withPath: filePathFullRez)
        storageRefFullRez.putData(fullRezData, metadata: metadata) { metadata, error in
            guard let metad = metadata else {
                print("putFullRezData no metadata")
                return
            }
            print("putFullRezData metad size", metad.size)
            // You can also access to download URL after upload.
            self.fetchDownloadURL_FullRez(storageRefFullRez,
                                          info: info,
                                          values: values,
                                          filePathFullRez: filePathFullRez)
        }
    }
    
    func fetchDownloadURL_FullRez(_ storageRefFullRez: StorageReference,
                                  info: [String: Any],
                                  values: [String: Any] ,
                                  filePathFullRez: String) {
        
        storageRefFullRez.downloadURL { url, error in
            guard let downloadURL = url else {
                print("fetchDownloadURL_FullRez download URL error : \(error.debugDescription)")
                return
            }
            // print("fetchDownloadURL download url:\n \(downloadURL) ")
            
            var nvalues = values;
            nvalues["mediaPathFullRez"] = downloadURL.description;
            nvalues["storagePathFullRez"] = filePathFullRez;
            
            self.createMediaEntry(info: info,
                                  values: nvalues,
                                  galleryRef: self.galleryRef,
                                  galleryKey: self.app.settings.storeGalleryKey,
                                  user: self.app.lobbyModel.currentUser);
        }
    }
    
    // Update editable properties of media item
    //  caption, videoUrl, isFavorite
    func updateMedia(media: MediaModel) {
        
        guard let galleryRef else { return }
        var values: [String: Any] = [:];
        values["caption"] = media.caption;
        values["previewUrl"] = media.previewUrl;
        values["loadPreviewUrl"] = media.loadPreviewUrl;
        values["isFavorite"] = media.isFavorite;
        galleryRef.child(media.id).updateChildValues(values) { error, ref in
            if let error = error {
                print("updateMediaEntry updateChildValues error: \(error).")
            }
        }
    }
    
    func createMediaEntry(info: [String: Any],
                          values: [String: Any],
                          galleryRef: DatabaseReference?,
                          galleryKey: String,
                          user: UserModel? ) {
        
        print("createMediaEntry storagePath", info["storagePath"] ?? "-nil-")
        print("createMediaEntry user", user ?? "-nil-")
        
        guard let galleryRef else { return }
        guard let user else { print("createMediaEntry no user"); return }
        
        let date = Date()
        var values = values;
        values["uid"] = user.id;
        values["authorEmail"] = user.email;
        values["uploadCount"] = user.uploadCount;
        values["createdAt"] = date.timeIntervalSinceReferenceDate;
        values["createdDate"] = date.description;
        values["info"] = info;
        
        guard let key = galleryRef.childByAutoId().key else {
            print("createMediaEntry no key");
            return
        }
        
        let userGalleryKey = user.userGalleryKey
        // let userGalleryKey = app.userGalleryKey(user: user)

        // If not linked and not in userGallery
        //  add to userGallery
        
        if values["homeRef"] == nil && app.settings.storeGalleryKey != userGalleryKey {
            
            let userGalleryRef = dbGalleryRef(key: userGalleryKey)
            guard let userGalleryRef else {
                print("createMediaEntry no userGalleryRef")
                return
            }
            guard let userGalleryChildId = userGalleryRef.childByAutoId().key else {
                print("createMediaEntry no userGalleryChildId")
                return
            }
            var nvalues = values;
            nvalues["homeRef"] = [galleryKey, key]
            userGalleryRef.child(userGalleryChildId).updateChildValues(nvalues) { error, ref in
                if let error = error {
                    print("createMediaEntry userGalleryRef updateChildValues error: \(error).")
                }
            }
            values["userGalleryChildId"] = userGalleryChildId;
        }
        
        galleryRef.child(key).updateChildValues(values) { error, ref in
            if let error = error {
                print("createMediaEntry updateChildValues error: \(error).")
            }
        }
        
        // Update user location
        app.lobbyModel.updateCurrentUser()
    }
    
    // Add the mediaItem to another gallery named galleryKey
    //  homeRef will point to the current source gallery
    //
    func createMediaEntry(galleryKey: String, mediaItem: MediaModel, setHomeRef: Bool = true) {
        
        var values: [String: Any] = [:];
        if setHomeRef {
            values["homeRef"] = [app.settings.storeGalleryKey, mediaItem.id]
        }
        let ngalleryRef = dbGalleryRef(key: galleryKey)
        
        values["mediaPath"] = mediaItem.mediaPath;
        values["storagePath"] = mediaItem.storagePath;
        // Copy full rez paths if present
        if !mediaItem.mediaPathFullRez.isEmpty {
            values["mediaPathFullRez"] = mediaItem.mediaPathFullRez;
        }
        if !mediaItem.storagePathFullRez.isEmpty {
            values["storagePathFullRez"] = mediaItem.storagePathFullRez;
        }
        
        values["isFavorite"] = mediaItem.isFavorite;
        values["caption"] = mediaItem.caption;
        values["previewUrl"] = mediaItem.previewUrl;
        values["loadPreviewUrl"] = mediaItem.loadPreviewUrl;

        // media copy reference is tagged with current user
        let user = app.lobbyModel.currentUser
        // let user = app.lobbyModel.user(uid: mediaItem.uid)
        createMediaEntry(info: mediaItem.info,
                         values: values,
                         galleryRef: ngalleryRef,
                         galleryKey: galleryKey,
                         user: user)
    }
    
    // Move the mediaItem to another gallery named galleryKey
    func moveMediaEntry(galleryKey: String, mediaItem: MediaModel) {
        
        print("moveMediaEntry galleryKey", galleryKey, "mediaItem", mediaItem)
        
        deleteMediaEntry(mediaItem: mediaItem)
        
        deleteMediaUserRef(mediaItem: mediaItem)

        createMediaEntry(galleryKey: galleryKey, mediaItem: mediaItem, setHomeRef: false);
    }
    
}
