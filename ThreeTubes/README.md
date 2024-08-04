# [98-MoGallery](https://github.com/mobilelabclass-itp/98-MoGallery)

MoGallery is a mobile app for students to quickly create their own mobile multi user experiences. It builds on the Apple SwiftUI tutorial that demonstrates access to the iOS Photo library and adds Google Firebase for multi user cloud storage features.

MoGallery is an iOS mobile template app for students to build on these features:

- Capture photos to store on device Photo Library or in user defined galleries in Firebase cloud storage.
- Share and Manage photo galleries with Firebase realtime database.
- Secure User login management with Google signin.
- Share photos beyond the app using web browser

p5js demo scripts to view Firebase storage in any web browser

- [98-MoGallery-p5js](https://github.com/molab-itp/98-MoGallery-p5js)

Created for NYU ITP Course:

- [ITP Mobile App Development Lab course](https://github.com/molab-itp/content-2023-fa)

## Requirements

- iPhone/iPad running iOS 16+, to run the app
- macOS 13+, for Xcode development

## Manifesto

Born of a need to share and collaborate free of evil profit-driven corporations.

- [use social media?](https://github.com/jht1493/jht-site#facts)

## References

- [Apple Tutorial - Browsing Your Photos](https://developer.apple.com/tutorials/sample-apps/capturingphotos-browsephotos)

- Firebase documentation

  - [Firebase database](https://firebase.google.com/docs/database/ios/read-and-write?hl=en&authuser=0)
  - [Firebase storage ](https://firebase.google.com/docs/storage/ios/start?hl=en&authuser=0)
  - [Firebase auth](https://firebase.google.com/docs/auth?hl=en&authuser=0)

- Firebase sample code

  - [Firebase Quickstarts for iOS](https://github.com/firebase/quickstart-ios)
  - [Firebase Database Quickstart](https://github.com/firebase/quickstart-ios/blob/master/database/README.md)
  - [Firebase Cloud Storage Quickstart](https://github.com/firebase/quickstart-ios/blob/master/storage/README.md)

- for google signin

  - [GoogleSignIn-iOS repo](https://github.com/google/GoogleSignIn-iOS)
  - [example project for Google Sign-In & Firebase Authentication Using SwiftUI](https://github.com/jht1493/Ellifit)

- YouTubePlayerKit
  - [YouTubePlayerKit](https://github.com/SvenTiigi/YouTubePlayerKit)

```

## Plan:

>> LimitedPicker nav view stays up after selection

## Log

[x] UserDetailView in MediaDetailView showInfoOverlay on authorEmail
[x] image upload storage prefixed with -mo/storePrefix
    uploadImageData
    let filePathPre = "-mo/\(app.settings.storePrefix)/\(uid)/\(user.uploadCount)"

[x] fix move leaving stray media item

[x] trigger limited selection view when in limited mode
https://developer.apple.com/documentation/photokit/phphotolibrary/3752108-presentlimitedlibrarypicker

https://stackoverflow.com/questions/63870238/how-to-call-phphotolibrary-presentlimitedlibrarypicker-from-swiftui

[x] return tuple (authorized, limited) from PhotoLibrary.checkAuthorization
print("Photo library access limited. 2023")
let authorized = await PhotoLibrary.checkAuthorization()
    var photoLibLimited = false;

[x] no update if media item deleted
    struct MediaDetailView
    private var deleted = false
    
[x] store prefix mo- --> mo-1/
>> store names mo-gallery --> mo-1/gallery

[x] Avoid PAAccessLogger] Failed to log access with error
Replace fileprivate let logger = Logger(subsystem:

class Camera: NSObject {
// !!@ force jpeg
// !!@ disable hevc

[x] HomeView
-> UsersView

[x] @StateObject var viewModel = AuthenticationViewModel()
AuthenticationViewModel -> UsersViewModel
viewModel -> usersModel

[x] final class DataModel: ObservableObject {
-> EnvironmentObject

[x] DataModel
-> PhotosModel

struct CameraView: View {
    @StateObject private var model = DataModel()
[x] model -> photosModel

>> Auth
 from [Google Sign-In & Firebase Authentication Using SwiftUI](
https://blog.codemagic.io/google-sign-in-firebase-authentication-using-swift/)
https://github.com/rudrankriyam/Ellifit

>> Packaged added
FirebaseAuth
FirebaseDatabase
FirebaseDatabaseSwift
FirebaseStorage

[x] upload to thumb to FireBase

>> func savePhoto(imageData: Data) {
upload

>> uiImage.scalePreservingAspectRatio
need to pickup orientation from cgimage

>> cgImage.resize
let cgImage = photo.cgImageRepresentation
gives incorrect orientation

>> private func unpackPhoto
modify to use cgImageRepresentation() to control resolution of image

Not sure how to get rid of entitlements file

>> on iphone13 photo capture test:
      print("photoDimensions", photoDimensions)
      print("previewDimensions", previewDimensions)
photoDimensions CMVideoDimensions(width: 4032, height: 3024)
previewDimensions CMVideoDimensions(width: 852, height: 640)

2022-12-17 JHT: Truely bizarre -
this code is extracted from
https://developer.apple.com/tutorials/sample-apps/capturingphotos-browsephotos
which is download as CapturingPhotos.swiftpm
which can be openned in xcode or swift playground app.
link [View a tutorial on this sample.] appears to only make sense in swift playground
I added [tutorial] which opens useless xcode browser link preview

>> example has deep logic that is only skimmed over in tutorial
>> needed to add Info.plist in xcode to allow for camera and photo library access
>> not sure how to do this via "Signing & Capabilities"

Update 2023-02-02

```

---

Below is the description of the original Apple tutorial used as a starting point for the app:

# Browsing Your Photos

Browse the photos in your photo library.

## Overview

Enjoy taking photos? Most of us do, and it’s easy to end up with hundreds or thousands of photos in your library. 🏞

Follow your photos as they’re retrieved from your photo library and displayed in a scrolling gallery you can browse.

## Tutorial

[View a tutorial on this sample.](doc://com.apple.documentation/tutorials/sample-apps/CapturingPhotos-BrowsePhotos)

[tutorial](https://developer.apple.com/tutorials/sample-apps/capturingphotos-browsephotos)

## Running the Sample Code Project

Before running this sample on a physical device, select a Development Team under the Signing & Capabilities section in the project editor.
