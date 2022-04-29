//
//  Builder.swift
//  Upload
//
//  Created by Елена Острожинская on 05.01.2022.
//

import Foundation
import UIKit
final class Builder {
    
    static let shared = Builder()
    private init() {}
    
    func buildLogin() -> UIViewController {
        let storyboard: UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        controller.modalPresentationStyle = .fullScreen
        return controller
    }
    
    func buildHome() -> UIViewController {
        let storyboard: UIStoryboard = UIStoryboard(name: "Download", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "DownloadController") as! DownloadController
        controller.modalPresentationStyle = .fullScreen
        return controller
    }
}
