//
//  ImageViewController.swift
//  Upload
//
//  Created by Елена Острожинская on 10.09.2021.
//

import Foundation
import UIKit
import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher
import Firebase
import SwiftyDropbox

class ImageViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    var image: UIImage?
    let googleDriveService = GTLRDriveService()
    var googleUser: GIDGoogleUser?
    var uploadFolderID = "123"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let image = self.image {
            imageView.image = image
        }
//        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
//
//        GIDSignIn.sharedInstance()?.delegate = self
//        GIDSignIn.sharedInstance()?.uiDelegate = self
//        GIDSignIn.sharedInstance()?.scopes = [kGTLRAuthScopeDrive]
//        GIDSignIn.sharedInstance()?.signIn()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: Notification.Name("authorized"), object: nil)

    }
    
    @objc func onDidReceiveData(_ notification: Notification) {
        let client = DropboxClientsManager.authorizedClient
        let fileData = "testing data example".data(using: String.Encoding.utf8, allowLossyConversion: false)!

        _ = client?.files.upload(path: "/new/Dropbox/account", input: fileData)

            .response { response, error in
                if let response = response {
                    print(response)
                } else if let error = error {
                    print(error)
                }
            }
            .progress { progressData in
                print(progressData)
            }
    }
    
    @IBAction func upload(_ sender: Any) {
      // uploadMyFile()
        uploadToDropBox()
    }
    
    func uploadToDropBox() {
         let scopeRequest = ScopeRequest(scopeType: .user, scopes: ["account_info.read", "files.content.write"], includeGrantedScopes: false)
         DropboxClientsManager.authorizeFromControllerV2(
             UIApplication.shared,
             controller: self,
             loadingStatusDelegate: nil,
             openURL: { (url: URL) -> Void in UIApplication.shared.openURL(url) },
             scopeRequest: scopeRequest
         )
    }
    
    func uploadMyFile() {
         let fileURL = Bundle.main.url(
             forResource: "snoopy", withExtension: ".png")
         uploadFile(
             name: "my-image.png",
             folderID: uploadFolderID,
             fileURL: fileURL!,
             mimeType: "image/png",
             service: googleDriveService)
     }
    
    func getFolderID(
        name: String,
        service: GTLRDriveService,
        user: GIDGoogleUser,
        completion: @escaping (String?) -> Void) {
        
        let query = GTLRDriveQuery_FilesList.query()

        // Comma-separated list of areas the search applies to. E.g., appDataFolder, photos, drive.
        query.spaces = "drive"
        
        // Comma-separated list of access levels to search in. Some possible values are "user,allTeamDrives" or "user"
        query.corpora = "user"
            
        let withName = "name = '\(name)'" // Case insensitive!
        let foldersOnly = "mimeType = 'application/vnd.google-apps.folder'"
        let ownedByUser = "'\(user.profile!.email!)' in owners"
        query.q = "\(withName) and \(foldersOnly) and \(ownedByUser)"
        
        service.executeQuery(query) { (_, result, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
                                     
            let folderList = result as! GTLRDrive_FileList

            // For brevity, assumes only one folder is returned.
            completion(folderList.files?.first?.identifier)
        }
    }
    
    func populateFolderID() {
           getFolderID(
               name: "my-folder",
               service: googleDriveService,
            user: googleUser!) { self.uploadFolderID = $0! }
       }
    
    func createFolder(
        name: String,
        service: GTLRDriveService,
        completion: @escaping (String) -> Void) {
        
        let folder = GTLRDrive_File()
        folder.mimeType = "application/vnd.google-apps.folder"
        folder.name = name
        
        // Google Drive folders are files with a special MIME-type.
        let query = GTLRDriveQuery_FilesCreate.query(withObject: folder, uploadParameters: nil)
        
        self.googleDriveService.executeQuery(query) { (_, file, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            
            let folder = file as! GTLRDrive_File
            completion(folder.identifier!)
        }
    }
    
    func uploadFile(
        name: String,
        folderID: String,
        fileURL: URL,
        mimeType: String,
        service: GTLRDriveService) {
        
        let file = GTLRDrive_File()
        file.name = name
        file.parents = [folderID]
        
        // Optionally, GTLRUploadParameters can also be created with a Data object.
        let uploadParameters = GTLRUploadParameters(fileURL: fileURL, mimeType: mimeType)
        
        let query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: uploadParameters)
        
        service.uploadProgressBlock = { _, totalBytesUploaded, totalBytesExpectedToUpload in
            // This block is called multiple times during upload and can
            // be used to update a progress indicator visible to the user.
        }
        
        service.executeQuery(query) { (_, result, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                fatalError(error!.localizedDescription)
            }
            
            // Successful upload if no error is returned.
        }
    }
}

extension ImageViewController: GIDSignInDelegate, GIDSignInUIDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        // A nil error indicates a successful login
        if error == nil {
            // Include authorization headers/values with each Drive API request.
            self.googleDriveService.authorizer = user.authentication.fetcherAuthorizer()
            self.googleUser = user
        } else {
            self.googleDriveService.authorizer = nil
            self.googleUser = nil
        }
        // ...
    }
}
