//
//  LoginViewController.swift
//  Upload
//
//  Created by Елена Острожинская on 17.11.2021.
//

import Foundation
import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var viewModel = LoginViewModel()

  
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        viewModel.login(email: email, password: password) {[weak self] result in
            switch result {
            case .success(let accessToken):
                let data = Data(accessToken.utf8)
                KeychainHelper.shared.save(data, service: "access-token", account: appNameAccount)
                DispatchQueue.main.async {
                    let controller = Builder.shared.buildHome()
                    self?.present(controller, animated: true, completion: nil)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
