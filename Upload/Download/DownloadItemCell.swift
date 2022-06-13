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
        if let exported = item.exported, exported.boolValue == true {
            markAsDowloaded()
        } else {
            markAsNotExported()
        }
    }
    
    func markAsDowloaded() {
        title.textColor = .gray
    }
    
    func markAsNotExported() {
        title.textColor = .black
    }
}

extension Int {
    var boolValue: Bool { return self != 0 }
}
