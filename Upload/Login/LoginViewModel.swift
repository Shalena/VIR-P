//
//  LoginViewModel.swift
//  Upload
//
//  Created by Елена Острожинская on 17.11.2021.
//

import Foundation

typealias LoginHandler = (Result<String, Error>) -> Void

class LoginViewModel: NSObject {
    
    func login(email: String, password: String, then handler: @escaping LoginHandler) {
        let session = URLSession.shared
        let url = URL(string: "https://vir-p.com/api/login")!
        let parameters = ["email": email, "password": password]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            } catch let error {
                print(error.localizedDescription)
            }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            if let error = error {
                handler(.failure(error))
            }
            if let data = data  {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        if let accessToken = json["access_token"] as? String {
                            handler(.success(accessToken))
                        }
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        })
            task.resume()
        }
    }
