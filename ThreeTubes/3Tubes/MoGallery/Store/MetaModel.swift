//
//  MetaModel.swift
//
//  Created by jht2 on 12/20/22.
//

import FirebaseDatabase

//private var moMetaKey = "mo-meta1"
//private var moMetaKey = "mo-meta"

class MetaModel: ObservableObject {
    
    @Published var metas: [MetaEntry] = []

    // mo-meta
    private var moMetaKey = "mo-meta"
    private var metaRef: DatabaseReference? 
    private var metaHandle: DatabaseHandle?
    var loaded: Bool = false
    var cleaned: Bool = true
    
    unowned var app: AppModel
    init(_ app:AppModel) {
        print("MetaModel init")
        self.app = app
        moMetaKey = app.settings.storePrefix + "meta"
        metaRef = Database.root.child(moMetaKey)
    }
    
    func allGalleryKeys() -> [String] {
        metas.map( { item in
            var ngalleryName = item.galleryName
            let pre = app.settings.storePrefix
            if item.galleryName.hasPrefix(pre) {
                ngalleryName = String(ngalleryName.dropFirst(pre.count))
            }
            return ngalleryName
        })
    }
    
    func refresh() {
        print("MetaModel refresh")
        observeStop()
        metaRef = Database.root.child(moMetaKey)
        observeStart()
    }
    
    func observeStart() {
        guard let metaRef else { return }
        print("MetaModel observeStart metaHandle", metaHandle ?? "nil")
        if metaHandle != nil {
            return;
        }
        metaHandle = metaRef.observe(.value, with: { snapshot in
            guard let snapItems = snapshot.value as? [String: [String: Any]] else {
                print("MetaModel meta EMPTY")
                self.metas = []
                self.loaded = true
                return
            }
            let items = snapItems.compactMap { MetaEntry(id: $0, dict: $1) }
            let sortedItems = items.sorted(by: { $0.galleryName < $1.galleryName })
            self.metas = sortedItems;
            print("MetaModel metas count", self.metas.count)
            // if (self.metas.count > 1000 && !self.cleaned) {
            if !self.cleaned {
                self.cleaned = true
                self.removeAllMetas()
            }
            self.loaded = true
        })
    }
    
    func removeAllMetas() {
        print("removeAllMetas metaRef", metaRef ?? "-nil-")
        guard let metaRef else { return }
//        metaRef.removeValue { error, ref in
//            if let error = error {
//                print("removeMeta removeValue error: \(error).")
//            }
//        }
        var count = 0
        for mentry in metas {
            if count % 1000 == 0 {
                print(count, "removeAllMetas mentry.id ", mentry.id)
            }
            count += 1
            metaRef.child(mentry.id).removeValue {error, ref in
                if let error = error {
                    print("removeAllMetas removeValue error: \(error).")
                }
            }
        }
        metas = []
    }
    
    func observeStop() {
        guard let metaRef else { return }
        print("MetaModel observeStop metaHandle", metaHandle ?? "nil")
        if let refHandle = metaHandle {
            metaRef.removeObserver(withHandle: refHandle)
            metaHandle = nil;
        }
    }
    
    func find(galleryName: String) -> MetaEntry? {
        return metas.first(where: { $0.galleryName == galleryName })
    }
    
    func fetch(galleryName: String) -> MetaEntry?  {
        print("fetch galleryName", galleryName);
        if let metaEntry = find(galleryName: galleryName) {
            return metaEntry
        }
        guard let user = app.lobbyModel.currentUser else {
            print("addMeta no currentUser")
            return nil
        }
        return addMeta(galleryName: galleryName, user: user)
    }
    
    func addMeta(galleryName: String) -> MetaEntry? {
        print("addMeta galleryName", galleryName);
        guard let user = app.lobbyModel.currentUser else {
            print("addMeta no currentUser")
            return nil
        }
        return addMeta(galleryName: galleryName, user: user)
    }
    
    func addMeta(galleryName: String, user: UserModel?) -> MetaEntry? {
        print("addMeta user galleryName", galleryName);
        print("addMeta loaded", loaded);
        
        // return nil; // !!@
        guard loaded else { return nil }
        
        let mentry = find(galleryName: galleryName)
        if let mentry  {
            print("addMeta present uid", mentry.uid);
            return mentry;
        }
        guard let user else {
            print("addMeta no currentUser")
            return nil
        }
        guard let metaRef else {
            print("addMeta no metaRef")
            return nil
        }
        guard let key = metaRef.childByAutoId().key else {
            print("addMeta no key")
            return nil
        }
        var values:[String : Any] = [:];
        values["uid"] = user.id;
        values["galleryName"] = galleryName;
        metaRef.child(key).updateChildValues(values) { error, ref in
            if let error = error {
                print("addMeta updateChildValues error: \(error).")
            }
        }
        let newEnt = MetaEntry(id: key, dict: values)
        metas.append( newEnt )
        return newEnt
    }
    
    func removeMeta(galleryName: String) {
        print("removeMeta galleryName", galleryName);
        guard let mentry = find(galleryName: galleryName)
        else {
            print("removeMeta NOT FOUND galleryName", galleryName)
            return;
        }
        // Delete from meta if this user is the creator
        guard let user = app.lobbyModel.currentUser else {
            print("addMeta no currentUser");
            return
        }
        if user.id != mentry.uid {
            print("removeMeta NOT owner mentry.uid", mentry.uid, "user.id", user.id)
            return
        }
        guard let metaRef else { return }
        metaRef.child(mentry.id).removeValue {error, ref in
            if let error = error {
                print("removeMeta removeValue error: \(error).")
            }
        }
    }
    
    // update the caption property
    func update(metaEntry: MetaEntry) {
        guard let metaRef else { return }
        var values:[String: Any] = [:];
        values["caption"] = metaEntry.caption;
        metaRef.child(metaEntry.id).updateChildValues(values) { error, ref in
            if let error = error {
                print("update metaEntry updateChildValues error: \(error).")
            }
        }
    }
}

