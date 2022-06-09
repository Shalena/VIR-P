//
//  DownloadContoller.swift
//  Upload
//
//  Created by Елена Острожинская on 17.11.2021.
//

import Foundation
import UIKit

class DownloadController: UIViewController {  
    @IBOutlet weak var tableView: UITableView!
    var viewModel = DownloadViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(refresh(_:)), name: Notification.Name("newPush"), object: nil)
        viewModel.delegate = self
        createSpinnerView()
        viewModel.downloadItems()
    }
    
    @IBAction func settingsPressed(_ sender: Any) {
        let settingsController = Builder.shared.buildSettings()
        show(settingsController, sender: self)
    }
    
    @objc func refresh(_ notification: Notification) {
        createSpinnerView()
        viewModel.downloadItems()
    }    
}


extension DownloadController: DownloadViewModelDelegate {
    func updateUI() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension DownloadController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "DownloadItemCell", for: indexPath) as? DownloadItemCell {
            cell.updateWith(item: viewModel.dataSource[indexPath.row])
            return cell
        }
        fatalError()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.dataSource[indexPath.row]
        let storyboard: UIStoryboard = UIStoryboard(name: "Download", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "DocumentController") as! DocumentController
        let viewModel = DocumentViewModel(item: item)
        controller.viewModel = viewModel
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true, completion: nil)
    }
}
