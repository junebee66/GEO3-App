//
//  MediaGalleryModel.swift
//  CaptureCameraStorage
//
//  Created by jht2 on 12/20/22.
//

import FirebaseDatabase

class GalleryModel: ObservableObject {
    
    private var galleryRef = Database.root.child("mo-gallery")
    private var galleryHandle: DatabaseHandle?

    @Published var gallery: [MediaModel] = []

    
    func observeMediaStart() {
        print("observeMediaStart mediaHandle", galleryHandle ?? "nil")
        if galleryHandle != nil {
            return;
        }
        galleryHandle = galleryRef.observe(DataEventType.value, with: { snapshot in
            // print("observeMediaStart snapshot", snapshot)
            guard let snapItems = snapshot.value as? [String: [String: Any]] else { return }
            let items = snapItems.compactMap { MediaModel(id: $0, dict: $1) }
            let sorteItems = items.sorted(by: { $0.createdAt > $1.createdAt })
            self.gallery = sorteItems;
            // print("observeMediaStart gallery", self.gallery)
            print("observeMediaStart gallery count", self.gallery.count)
        })
    }
    
    func observeMediaStop() {
        print("observeMediaStop mediaHandle", galleryHandle ?? "nil")
        if let refHandle = galleryHandle {
            galleryRef.removeObserver(withHandle: refHandle)
            galleryHandle = nil;
        }
    }
}

