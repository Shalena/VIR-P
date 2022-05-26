//
//  DownloadItemCell.swift
//  Upload
//
//  Created by Елена Острожинская on 17.11.2021.
//

import Foundation
import UIKit

class DownloadItemCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
       
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func updateWith(item: DownloadItem) {
        if let id = item.id,
           let name = item.name {
            let text = "Id: " + String(id)  + "   " + name
            title.text = text
        }
    }
    
    func markAsDowloaded() {
        title.textColor = .gray
    }
}
