//
//  SettingsViewModel.swift
//  Upload
//
//  Created by Елена Острожинская on 06.06.2022.
//

import Foundation

class SettingsViewModel: NSObject {
    
    func currentPushToken() -> String? {
        if let data = KeychainHelper.shared.read(service: "push-token", account: appNameAccount) {
            return String(data: data, encoding: .utf8)
        } else {
            return fakeDeviceToken
        }
    }
    
    func logout() {
        KeychainHelper.shared.delete(service: "push-token", account: appNameAccount)
        KeychainHelper.shared.delete(service: "access-token", account: appNameAccount)
    }
}
    
    
