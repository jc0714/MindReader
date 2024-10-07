//
//  AlbumCell.swift
//  MindReader
//
//  Created by J oyce on 2024/9/20.
//

import Foundation
import UIKit
import Kingfisher

class AlbumCell: UICollectionViewCell {
    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.frame = self.contentView.bounds
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "photo7")
        self.contentView.addSubview(imageView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with url: URL) {
        imageView.kf.setImage(with: url, placeholder: UIImage(named: "photo7"))
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.image = UIImage(named: "photo7")
    }
}
