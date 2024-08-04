/*
See the License.txt file for this sample’s licensing information.
*/

import Photos
import os.log

class PhotoLibrary {

    static func checkAuthorization() async -> (Bool, PHAuthorizationStatus) {
        let stat = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch stat {
        case .authorized:
            print("Photo library access authorized.")
            return (true, stat)
        case .notDetermined:
            print("Photo library access not determined.")
            return (await PHPhotoLibrary.requestAuthorization(for: .readWrite) == .authorized, stat)
        case .denied:
            print("Photo library access denied.")
            return (false, stat)
        case .limited:
            print("Photo library access limited. 2023")
            // return false
            // 2023-08-20 jht: Allow for limited photo access
            return (true, stat)
        case .restricted:
            print("Photo library access restricted.")
            return (false, stat)
        @unknown default:
            return (false, stat)
        }
    }
}

//fileprivate let logger = Logger(subsystem: "com.jht1900.CaptureCameraStorage", category: "PhotoLibrary")

