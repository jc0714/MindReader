//
//  ButtonExtension.swift
//  MindReader
//
//  Created by J oyce on 2024/9/18.
//

import Foundation
import UIKit

extension UIButton {
    static func styledButton(title: String, backgroundColor: UIColor, titleColor: UIColor = .white) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 3, height: 3)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 5
        button.layer.borderColor = UIColor.milkYellow.cgColor
        button.layer.borderWidth = 2
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return button
    }
}
