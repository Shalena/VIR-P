//
//  DocumentViewModel.swift
//  Upload
//
//  Created by Елена Острожинская on 17.11.2021.
//

import Foundation


class DocumentViewModel: NSObject {
    var item: DownloadItem
    var accessToken = ""
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
    
}

protocol DocumentViewModelDelegate: BaseControllerDelegate {
    func uploadedFromServer()
}

