//
//  AppModel_video.swift
//  MoGallery
//
//  Created by jht2 on 8/19/23.
//

import SwiftUI
import Photos
import YouTubePlayerKit

extension AppModel {
    
    func playVideo(url ref: String) {
        // https://bit.ly/swswift
        // https://jht1493.net/macr/mov/sample_640x360.mp4
        print("playVideo url", ref)
        if ref.hasPrefix("https://youtu.be/") ||
            ref.hasPrefix("https://youtube.com/") ||
            ref.hasPrefix("https://www.youtube.com/"
            ) {
            playVideo(youTubeUrl: ref)
        }
        else if !ref.hasPrefix("https://") {
            playVideo(youTubeId: ref)
        }
        else if ref.hasSuffix(".mp4") {
            guard let url = URL(string: ref) else {
                print("playVideo url failed")
                return
            }
            videoPlayer = AVPlayer(url: url);
            videoPlayer?.play()
        }
    }
    
    func playVideo(youTubeId ref: String) {
        print("playVideo youTubeId ref", ref)
        // youTubePlayer = "https://youtube.com/watch?v=psL_5RIBqnY"
        youTubePlayer = YouTubePlayer(
            source: .video(id: ref),
            configuration: .init(
                autoPlay: true,
                loopEnabled: true
            )
        )
    }
    
    func playVideo(youTubeUrl ref: String) {
        print("playVideo youTubeUrl ref", ref)
        // https://youtube.com/watch?v=psL_5RIBqnY
        // https://youtu.be/-Vmv9BMv7AQ
        youTubePlayer = YouTubePlayer(
            source: .url(ref),
            configuration: .init(
                autoPlay: true,
                loopEnabled: true
            )
        )
    }
    
    func playVideo(phAsset: PHAsset) {
        let manager = PHImageManager.default()
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        manager.requestPlayerItem( forVideo: phAsset, options: options ) {
            playerItem, info in
            print("playVideo playerItem", playerItem ?? "-nil-")
            print("playVideo info", info ?? "-nil-")
            self.videoPlayer = AVPlayer(playerItem: playerItem)
            self.videoPlayer?.play()
        }
    }
    
    func stopVideo() {
        print("videoStop")
        youTubePlayer = nil
        videoPlayer = nil
    }
    
}
