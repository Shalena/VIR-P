//
//  ViewController.swift
//  Upload
//
//  Created by Елена Острожинская on 10.09.2021.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    @IBAction func downloadFile(_ sender: Any) {
        downloadFile()
    }
    

    
    func downloadFile() {
        let session = URLSession.shared
        let url = URL(string: "https://dummyimage.com/300")!

        let task = session.dataTask(with: url) { data, response, error in
            if error != nil || data == nil {
                print("Client error!")
                return
            } else {
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let controller = storyboard.instantiateViewController(withIdentifier: "ImageViewController") as! ImageViewController
                        controller.image = image
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }
            }
        }
        task.resume()
    }
}

