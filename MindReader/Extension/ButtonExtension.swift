//
//  ButtonExtension.swift
//  MindReader
//
//  Created by J oyce on 2024/9/18.
//

import Foundation
import UIKit

extension UIViewController {
//    func createButton(title: String, backgroundColor: UIColor, titleColor: UIColor = .white, action: Selector) -> UIButton {
//        let button = UIButton(type: .system)
//        button.setTitle(title, for: .normal)
//        button.setTitleColor(titleColor, for: .normal)
//        button.backgroundColor = backgroundColor
//        button.layer.cornerRadius = 10
//        button.addTarget(self, action: action, for: .touchUpInside)
//        return button
//    }
    func createButton(title: String, backgroundColor: UIColor, titleColor: UIColor = .white, action: Selector) -> UIButton {
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
            button.layer.masksToBounds = false

            button.layer.borderColor = UIColor.white.cgColor
            button.layer.borderWidth = 2

            button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

            button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
            button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside])

            button.addTarget(self, action: action, for: .touchUpInside)
            return button
        }

        @objc private func buttonTouchDown(_ sender: UIButton) {
            UIView.animate(withDuration: 0.1) {
                sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }
        }

        @objc private func buttonTouchUp(_ sender: UIButton) {
            UIView.animate(withDuration: 0.1) {
                sender.transform = .identity
            }
        }
}
