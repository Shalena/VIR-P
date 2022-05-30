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
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        clearKeychainIfWillUnistall()
        FirebaseApp.configure()
        DropboxClientsManager.setupWithAppKey("y30emrqx9qw3omw")
        ODClient.setActiveDirectoryAppId("bca59b63-67b3-4b67-9f94-f4ca7153b4a3", redirectURL: "msauth.com.upload://auth")
        registerForPushNotifications()
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
    
    func registerForPushNotifications() {
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
          print("Permission granted: \(granted)")
          guard granted else {
              return
          }
          self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        print("Notification settings: \(settings)")
          guard settings.authorizationStatus == .authorized else { return }
          DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
          }
      }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
      let newtoken = tokenParts.joined()
      print("Fresh Device Token: \(newtoken)")
        if let data = KeychainHelper.shared.read(service: "push-token", account: appNameAccount),
           let oldtoken = String(data: data, encoding: .utf8) {
           print("Old Device Token: \(oldtoken)")            
        }
      let newData = Data(newtoken.utf8)
        KeychainHelper.shared.delete(service: "push-token", account: appNameAccount)
      KeychainHelper.shared.save(newData, service: "push-token", account: appNameAccount)
    }
    
  //  func application(
//      _ application: UIApplication,
//      didReceiveRemoteNotification userInfo: [AnyHashable: Any],
//      fetchCompletionHandler completionHandler:
//      @escaping (UIBackgroundFetchResult) -> Void) {
//      guard let aps = userInfo["aps"] as? [String: AnyObject] else {
//        completionHandler(.failed)
//
//        return
//      }
//    }
    
    func application(
      _ application: UIApplication,
      didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
      print("Failed to register: \(error)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,  willPresent notification: UNNotification, withCompletionHandler   completionHandler: @escaping (_ options:   UNNotificationPresentationOptions) -> Void) {
        print("Handle push from foreground")
        // custom code to handle push while app is in the foreground
        print("\(notification.request.content.userInfo)")
        
     }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Handle push from background or closed")
        // if you set a member variable in didReceiveRemoteNotification, you  will know if this is from closed or background
        print("\(response.notification.request.content.userInfo)")
        let userInfo = response.notification.request.content.userInfo
        guard let aps = userInfo["aps"] as? [String: AnyObject] else {
            return
        }
    }
}

