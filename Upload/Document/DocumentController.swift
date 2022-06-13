//
//  DocumentController.swift
//  Upload
//
//  Created by Елена Острожинская on 17.11.2021.
//

import Foundation
import UIKit
import SwiftyDropbox
import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher
import Firebase
import OneDriveSDK

class DocumentController: UIViewController {
    
    @IBOutlet weak var saveTpGoogle: UIButton!
    @IBOutlet weak var saveToDropbox: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    var viewModel: DocumentViewModel?
    
    let googleDriveService = GTLRDriveService()
    var googleUser: GIDGoogleUser?
    var oneDriveClient: ODClient?
    var uploadFolderID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closeButton.clipsToBounds = true
        closeButton.imageView?.contentMode = .scaleAspectFit
        viewModel?.delegate = self
        titleLabel.text = viewModel?.item.name
        viewModel?.downloadDocument()        
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: Notification.Name("authorized"), object: nil)
        initialSetupForGoogleDrive()
    }
    
    private func initialSetupForGoogleDrive() {
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance()?.scopes = [kGTLRAuthScopeDrive, kGTLRAuthScopeDriveAppdata]
    }
    
    @IBAction func closeAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func onDidReceiveData(_ notification: Notification) {
       uploadFileToDropbox()
    }
    
    func uploadFileToDropbox() {
        guard let fileName = viewModel?.item.name else {return}
        guard let fileData = viewModel?.fileData else {return}
        let client = DropboxClientsManager.authorizedClient
        _ = client?.files.upload(path: "/" + fileName, input: fileData)
            .response { [self] response, error in
                if response != nil {
                    viewModel?.markAsDownloaded()
                    self.showAlert(message: "Uploaded successfully, please check your Dropbox")
                  //  self.twoOptionCancelAlert(message: "Do you want to save Dropbox as preffered Cloud Store?", actionTitle: "Save")
                } else if let error = error {
                    self.showAlert(message: error.description)
                }
            }
            .progress { progressData in
                print(progressData)
            }
    }
    
    @IBAction func saveTpDropbox(_ sender: Any) {
        let scopeRequest = ScopeRequest(scopeType: .user, scopes: ["account_info.read", "files.content.write"], includeGrantedScopes: false)
        if DropboxClientsManager.authorizedClient == nil {
            DropboxClientsManager.authorizeFromControllerV2(
                UIApplication.shared,
                controller: self,
                loadingStatusDelegate: nil,
                openURL: { (url: URL) -> Void in UIApplication.shared.openURL(url) },
                scopeRequest: scopeRequest
            )
        } else {
            uploadFileToDropbox()
        }
    }
    
    @IBAction func saveToGoogleDrive(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @IBAction func saveToiCloud(_ sender: Any) {
        do {
            let fm = FileManager.default
            if let driveURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
                try? fm.createDirectory(at: driveURL, withIntermediateDirectories: false, attributes: nil)
                if let fileName = viewModel?.item.name {
                   let url = driveURL.appendingPathComponent(fileName)
                   try viewModel?.fileData?.write(to: url)
                   viewModel?.markAsDownloaded()
                   showAlert(message: "Uploaded successfully, please check your iCloud store")
                }
            } else {
                showAlert(message: "Please Sign in to your iPhone")
            }
        } catch {
            showAlert(message: error.localizedDescription)
        }
    }
    
    @IBAction func saveToOneDrive(_ sender: Any) {
    ODClient.setParentAuthController(self)
    ODClient.authenticatedClient(completion: { (odclient, error) in
          if odclient != nil {
            self.oneDriveClient = odclient
          } else if error != nil {
            self.showAlert(message: error!.localizedDescription)
          }
    })
}
    
    private func populateFolderID() {
        let myFolderName = "Vir-P"
        let uploadBlock = {
            self.upload((self.uploadFolderID!), name: (self.viewModel?.item.name)!, data: (self.viewModel?.fileData)!, MIMEType: "image/png") { string, error in
                    if string != nil {
                        viewModel?.markAsDownloaded()
                        self.showAlert(message: "Uploaded successfully, please check your Google Drive")
                    } else if error != nil {
                        self.showAlert(message: error!.localizedDescription)
                    }
                }
            }
    
        getFolderID( name: myFolderName,
                  service: googleDriveService,
                     user: googleUser!) { [weak self] folderID in
        if folderID == nil {
            self?.createFolder(name: myFolderName,
                            service: self!.googleDriveService) {
                self?.uploadFolderID = $0
                uploadBlock()
            }
        } else {
            self?.uploadFolderID = folderID
            uploadBlock()
        }
    }
}
    
   private func getFolderID(
        name: String,
        service: GTLRDriveService,
        user: GIDGoogleUser,
        completion: @escaping (String?) -> Void) {
        let query = GTLRDriveQuery_FilesList.query()
        query.spaces = "drive"
        query.corpora = "user"
        let withName = "name = '\(name)'"
        let foldersOnly = "mimeType = 'application/vnd.google-apps.folder'"
        let ownedByUser = "'\(user.profile!.email!)' in owners"
        query.q = "\(withName) and \(foldersOnly) and \(ownedByUser)"
        service.executeQuery(query) { (_, result, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            let folderList = result as! GTLRDrive_FileList
            completion(folderList.files?.first?.identifier)
        }
    }
    
   private func createFolder(
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
    
    private func upload(_ parentID: String, name: String, data: Data, MIMEType: String, onCompleted: ((String?, Error?) -> ())?) {
        let metadata: GTLRDrive_File = GTLRDrive_File()
        metadata.name = name
        metadata.parents = [parentID]

        let uploadParameters: GTLRUploadParameters = GTLRUploadParameters(data: data, mimeType: "application/octet-stream")
        uploadParameters.shouldUploadWithSingleRequest = true;
        let query: GTLRDriveQuery_FilesCreate = GTLRDriveQuery_FilesCreate.query(withObject: metadata, uploadParameters: uploadParameters)
         query.fields = "id"
         self.googleDriveService.executeQuery(query) { (ticket, fileN, error) in
            var fileIdentifier: String?
            if let f = fileN as? GTLRDrive_File {
                if (error == nil) {
                    fileIdentifier = f.identifier as? String
                } else {
                    print("An error occurred: %@", error)
                }
            }
             onCompleted!(fileIdentifier, error)
        }
    }
}

extension DocumentController: DocumentViewModelDelegate {
    func uploadedFromServer() {
        saveTpGoogle.isHidden = false
        saveToDropbox.isHidden = false
    }
}

extension DocumentController: GIDSignInDelegate, GIDSignInUIDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error == nil {
            self.googleDriveService.authorizer = user.authentication.fetcherAuthorizer()
            self.googleUser = user
            populateFolderID()
        } else {
            self.googleDriveService.authorizer = nil
            self.googleUser = nil
        }
    }
}
