//
//  DownloadViewModel.swift
//  Upload
//
//  Created by Елена Острожинская on 17.11.2021.
//

import Foundation

class DownloadViewModel: NSObject {
    var delegate: DownloadViewModelDelegate?
    var dataSource = [DownloadItem]()
    
    func downloadItems() {
        let session = URLSession.shared
        let urlString = "https://vir-p.com/api/files"
        let url = URL(string: urlString)!
      
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        guard let data = KeychainHelper.shared.read(service: "access-token", account: appNameAccount),
              let accessToken = String(data: data, encoding: .utf8) else {return}
            
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(accessToken, forHTTPHeaderField: "Authorization")
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            if let error = error {
               
            }
            if let data = data  {
                do {
                    let jsonDecoder = JSONDecoder()
                    let itemsWrap = try jsonDecoder.decode(DownloadItemWrap.self, from: data)
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        print(json)
                    }
                    if let items = itemsWrap.items {
                        self.dataSource = items
                        self.delegate?.updateUI()
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        })
            task.resume()
        }
    }
    

protocol DownloadViewModelDelegate: class {
    func updateUI()
}
