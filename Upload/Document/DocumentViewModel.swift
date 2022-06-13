//
//  DocumentViewModel.swift
//  Upload
//
//  Created by Елена Острожинская on 17.11.2021.
//

import Foundation


class DocumentViewModel: NSObject {
    var item: DownloadItem
    var fileData: Data?
    var delegate: DocumentViewModelDelegate?

    init (item: DownloadItem) {
        self.item = item
    }
    
    func downloadDocument() {
    let session = URLSession.shared
    let urlString = "https://vir-p.com/api/files/" + String(item.id ?? 0) + "/data"
    let url = URL(string: urlString)!
  
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    guard let data = KeychainHelper.shared.read(service: "access-token", account: appNameAccount),
              let accessToken = String(data: data, encoding: .utf8) else {return}
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue(accessToken, forHTTPHeaderField: "Authorization")
    delegate?.showSpinner()
    let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
        if let error = error {
            self.delegate?.showAlert(message: error.localizedDescription)
        }
        if let data = data  {
            self.fileData = data
            DispatchQueue.main.async {
                self.delegate?.uploadedFromServer()
            }
        }
    })
        task.resume()
    }
    
    func markAsDownloaded() {
        let session = URLSession.shared
        let urlString = "https://vir-p.com/api/files/" + String(item.id ?? 0)
        let url = URL(string: urlString)!
      
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        let parameters: [String: Any] = ["exported": true]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let data = KeychainHelper.shared.read(service: "access-token", account: appNameAccount),
              let accessToken = String(data: data, encoding: .utf8) else {return}
        request.addValue(accessToken, forHTTPHeaderField: "Authorization")
        delegate?.showSpinner()
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            if let error = error {
                self.delegate?.showAlert(message: error.localizedDescription)
            }
            if let data = data  {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        print(json)
                        
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            }
            if let response = response {
                print (response)
                
            }
        })
            task.resume()
    }
    
}

protocol DocumentViewModelDelegate: BaseControllerDelegate {
    func uploadedFromServer()
}

