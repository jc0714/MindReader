//
//  UIImageViewExtension.swift
//  MindReader
//
//  Created by J oyce on 2024/11/14.
//

import Foundation
import Kingfisher
import UIKit

extension UIImageView {
    func setImage(from url: String, placeholder: UIImage? = nil, fadeDuration: Double = 0.2) {
        guard let imageURL = URL(string: url) else {
            print("Invalid URL string")
            return
        }

        self.kf.setImage(
            with: imageURL,
            placeholder: placeholder,
            options: [
                .transition(.fade(fadeDuration)),
                .cacheOriginalImage
            ]
        ) { result in
            switch result {
            case .success:
                self.setNeedsLayout()
                self.layoutIfNeeded()
            case .failure(let error):
                print("Image load failed: \(error)")
            }
        }
    }
}
