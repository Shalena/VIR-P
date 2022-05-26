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
    
    func twoOptionCancelAlert(message: String, title: String = "", actionTitle: String) {
      let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
      let action = UIAlertAction(title: actionTitle, style: .default, handler: nil)
      let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
      alertController.addAction(cancelAction)
      alertController.addAction(action)        
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
