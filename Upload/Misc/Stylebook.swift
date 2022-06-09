//
//  Stylebook.swift
//  Upload
//
//  Created by Елена Острожинская on 08.06.2022.
//

import Foundation
import UIKit

class BorderedButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.borderWidth = 1.0
        layer.borderColor = tintColor.cgColor
        layer.cornerRadius = 5.0
        clipsToBounds = true
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        setTitleColor(tintColor, for: .normal)
        setTitleColor(UIColor.white, for: .highlighted)
    }
}
