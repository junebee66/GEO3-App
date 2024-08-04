// LobbyModel
//

import Firebase
import GoogleSignIn
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class LobbyModel: ObservableObject {
    enum SignInState {
        case signedIn
        case signedOut
    }
    @Published var state: SignInState = .signedOut
    @Published var users: [UserModel] = []
    var currentUser: UserModel?

    private var mediaRef = Database.root.child("mo-gallery")
    
    private var lobbyRef = Database.root.child("mo-lobby")
    private var lobbyHandle: DatabaseHandle?
    
    private var storage = Storage.storage()

    // var uploadCount: Int = 0;

    func signIn() {
        print("LobbyModel signIn", state)
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in
                authenticateUser(for: user, with: error)
                // state = .signedIn
                setSignedIn();
            }
        } else {
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
            let configuration = GIDConfiguration(clientID: clientID)
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
            GIDSignIn.sharedInstance.signIn(with: configuration, presenting: rootViewController) { [unowned self] user, error in
                // GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [unowned self] signInResult, error in
                self.authenticateUser(for: user, with: error)
                // self.authenticateUser(for: signInResult?.user, with: error)
            }
        }
    }
    
    private func authenticateUser(for user: GIDGoogleUser?, with error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        guard let authentication = user?.authentication, let idToken = authentication.idToken else { return }
        // guard let user = user else { return }
        
        // version 7 needs right credential
        // - Removed `authentication` property and replaced it with:
        // - New `accessToken` property.
        // - New `idToken` property.
        // let idToken = user.idToken;
        // let accessToken = user.accessToken;
        // let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { [unowned self] (_, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                // state = .signedIn
                setSignedIn()
            }
        }
    }
    
    func setSignedIn() {
        if state != .signedIn {
            state = .signedIn
            updateCurrentUser()
        }
//        let id = Auth.auth().currentUser?.uid ?? ""
//        let guser = GIDSignIn.sharedInstance.currentUser;
//        let name = guser?.profile?.name ?? ""
//        let email = guser?.profile?.email ?? ""
//        let profileImg = guser?.profile?.imageURL(withDimension: 80)?.description ?? ""
//        let dateIn = 0.0;
//        currentUser = UserModel(id: id, name: name, email: email, profileImg: profileImg, dateIn: dateIn)
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        do {
            try Auth.auth().signOut()
            state = .signedOut
            currentUser = nil
        } catch {
            print(error.localizedDescription)
        }
    }
    
//    func getCurrentUser() -> User? {
//        return Auth.auth().currentUser
//    }
    
    // First time user is inited in mo-users
    // update db user property dateIn with current time in seconds
    // db: mo-users
    // user db properties:
    //  email
    //  name
    //  profileImg
    //  dateIn
    //
    func updateCurrentUser() {
        // guard let user = currentUser else { return }
        // guard let guser = GIDSignIn.sharedInstance.currentUser else { return }
        // let profileName = user.name
        // let profileImg = user.profileImg
        // let dateIn = Date().timeIntervalSinceReferenceDate;
        
        let id = Auth.auth().currentUser?.uid ?? ""
        let guser = GIDSignIn.sharedInstance.currentUser;
        let name = guser?.profile?.name ?? ""
        let email = guser?.profile?.email ?? ""
        let profileImg = guser?.profile?.imageURL(withDimension: 80)?.description ?? ""
        let dateIn = Date().timeIntervalSinceReferenceDate

        var values:[String : Any] = [:];
        values["name"] = name
        values["email"] = email
        values["profileImg"] = profileImg
        values["dateIn"] = dateIn;

        // Probe db for user by checking name property
        lobbyRef.child("\(id)").getData() { error, snapshot in
            guard error == nil else {
                print("postUser getData error",error!.localizedDescription)
                return;
            }
            if let dict = snapshot?.value as? [String: Any] {
                values["uploadCount"] = dict["uploadCount"]
            }
            else {
                values["uploadCount"] = 0
            }
            print("updateCurrentUser values", values);
            
            // Update db user properies
            self.lobbyRef.child(id).updateChildValues(values) { error, ref in
                if let error = error {
                    print("postUser updateChildValues error: \(error).")
                }
            }
            self.currentUser = UserModel(id: id, dict: values)
        }
        
//        usersRef.child("\(user.uid)").getData() { error, snapshot in
//            guard error == nil else {
//                print("postUser getData error",error!.localizedDescription)
//                return;
//            }
//            print("postUser getData snapshot", snapshot)
//        }
    }
    
    func observeUsersStart() {
        print("observeUsersStart usersHandle", lobbyHandle ?? "nil")
        if lobbyHandle != nil {
            return;
        }
        lobbyHandle = lobbyRef.observe(DataEventType.value, with: { snapshot in
            // print("observeUsersStart snapshot", snapshot)
            guard let snapUsers = snapshot.value as? [String: [String: Any]] else { return }
            let items = snapUsers.compactMap { UserModel(id: $0, dict: $1) }
            let sortedItems = items.sorted(by: { $0.dateIn > $1.dateIn })
            self.users = sortedItems;
            // print("observeUsersStart users", self.users)
            print("observeUsersStart users.count", self.users.count)
        })
    }
    
    func observeUsersStop() {
        print("observeUsersStop usersHandle", lobbyHandle ?? "nil")
        if let refHandle = lobbyHandle {
            lobbyRef.removeObserver(withHandle: refHandle)
            lobbyHandle = nil;
        }
    }
    
    func uploadFromData(_ imageData: Data) {
        guard let user = currentUser else {
            print("uploadFromData no currentUser");
            return
        }

        // upload filepath is user id + uploadCount
        let uid = user.id
        let filePath = uid + "/\(user.uploadCount).jpeg"
        
        var values:[AnyHashable : Any] = [:];
        values["uploadCount"] = ServerValue.increment(1);
        self.lobbyRef.child(user.id).updateChildValues(values) { error, ref in
            if let error = error {
                print("uploadFromData uploadCount error: \(error).")
            }
        }
        // !!@ May get out of sync with users logged in multiple times
        // !!@ Need to observe current user
        user.uploadCount += 1;

        // upload to path with user id and time stamp
        //    let filePath = Auth.auth().currentUser!.uid +
        //      "/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/fromData/\(imageURL.lastPathComponent)"
        
        let storageRef = storage.reference(withPath: filePath)
        
        // Create file metadata including the content type
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        metadata.cacheControl = "public,max-age=300"
        
//        Task { @MainActor in
//            self.isLoading = true
//            uploadCount += 1;
//        }
        storageRef.putData(imageData, metadata: metadata) { metadata, error in
            guard let metad = metadata else {
                // Uh-oh, an error occurred!
//                self.errorFound = true
//                self.errInfo = error
                return
            }
            print("uploadFromData metad size", metad.size)
            Task { @MainActor in
//                self.isLoading = false
            }
            // You can also access to download URL after upload.
            self.fetchDownloadURL(storageRef, storagePath: filePath)
        }
    }
    
    func fetchDownloadURL(_ storageRef: StorageReference, storagePath: String) {
        storageRef.downloadURL { url, error in
            guard let downloadURL = url else {
                print("fetchDownloadURL download URL error : \(error.debugDescription)")
//                self.errorFound = true
//                self.errInfo = error
                return
            }
            // print("fetchDownloadURL download url:\n \(downloadURL) ")
            
            self.createMediaEntry(mediaPath: downloadURL.description);
        }
    }

    func createMediaEntry(mediaPath:String) {
        print("createMediaEntry mediaPath", mediaPath)
        guard let user = currentUser else {
            print("createMediaEntry no currentUser");
            return
        }
        
        var values:[AnyHashable : Any] = [:];
        values["uid"] = user.id;
        values["authorEmail"] = user.email;
        values["uploadCount"] = user.uploadCount;
        values["mediaPath"] = mediaPath;
        values["createdAt"] = Date().timeIntervalSinceReferenceDate;

        guard let key = mediaRef.childByAutoId().key else {
            print("createMediaEntry no key");
            return
        }
        mediaRef.child(key).updateChildValues(values) { error, ref in
            if let error = error {
                print("postUser updateChildValues error: \(error).")
            }
        }

    }
}

extension Database {
    class var root: DatabaseReference {
        return database().reference()
    }
}

//
//  derived from:
// https://github.com/rudrankriyam/Ellifit
// require google signin verion 6.x
