//
//  AppDelegate.swift
//  Upload
//
//  Created by Елена Острожинская on 10.09.2021.
//

import UIKit
import Firebase
import GoogleSignIn
import SwiftyDropbox
import OneDriveSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        clearKeychainIfWillUnistall()
        FirebaseApp.configure()
        DropboxClientsManager.setupWithAppKey("y30emrqx9qw3omw")
        ODClient.setActiveDirectoryAppId("bca59b63-67b3-4b67-9f94-f4ca7153b4a3", redirectURL: "msauth.com.upload://auth")
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let oauthCompletion: DropboxOAuthCompletion = {
          if let authResult = $0 {
              switch authResult {
              case .success:
                  print("Success! User is logged into DropboxClientsManager.")
              case .cancel:
                  print("Authorization flow was manually canceled by user!")
              case .error(_, let description):
                  print("Error: \(String(describing: description))")
              }
          }
        }
        let canHandleUrl = DropboxClientsManager.handleRedirectURL(url, completion: oauthCompletion)
        return canHandleUrl
    }
    
    func clearKeychainIfWillUnistall() {
        let freshInstall = !UserDefaults.standard.bool(forKey: "alreadyInstalled")
        if freshInstall {
            KeychainHelper.shared.delete(service: "access-token", account: appNameAccount)
            UserDefaults.standard.set(true, forKey: "alreadyInstalled")
        }
    }
}

