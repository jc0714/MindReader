//
//  ImageCell.swift
//  MindReader
//
//  Created by J oyce on 2024/9/22.
//

import Foundation
import UIKit

class ImageCell: UICollectionViewCell {
    var imageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView(frame: contentView.bounds)
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with url: URL) {
        imageView.kf.setImage(with: url)
    }
}
