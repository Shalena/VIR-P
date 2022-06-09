//
//  SettingsViewController.swift
//  Upload
//
//  Created by Елена Острожинская on 06.06.2022.
//

import Foundation

import Foundation
import UIKit

class SettingsViewController: UIViewController {
      
    @IBOutlet weak var currentToken: UILabel!
    var viewModel = SettingsViewModel()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        currentToken.text = viewModel.currentPushToken()
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func logout(_ sender: Any) {
        viewModel.logout()
        view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
}
    
