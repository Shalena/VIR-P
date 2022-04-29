//
//  BaseControllerDelegate.swift
//  Upload
//
//  Created by Елена Острожинская on 18.11.2021.
//

import Foundation
import UIKit

extension UIViewController {
    
  func alert(message: String, title: String = "") {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(OKAction)
    self.present(alertController, animated: true, completion: nil)
  }
}

protocol BaseControllerDelegate: class where Self: UIViewController {
    
}

extension BaseControllerDelegate {
    func showAlert(message: String, title: String = "") {
        alert(message: message, title: title)
    }
    
    func showSpinner() {
        createSpinnerView()
    }
}
