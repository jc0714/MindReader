//
//  PostCell.swift
//  MindReader
//
//  Created by J oyce on 2024/9/15.
//

import Foundation
import UIKit

class PostCell: UITableViewCell {

    let articleTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 20)
        label.backgroundColor = .yellow
        return label
    }()

    let authorName: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()

    let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.backgroundColor = UIColor.lightGray
        label.textAlignment = .center
        return label
    }()

    let createdTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        return label
    }()

    let contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    let postImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {

        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true

        addSubview(articleTitle)
        addSubview(authorName)
        addSubview(categoryLabel)
        addSubview(createdTimeLabel)
        addSubview(contentLabel)
        addSubview(postImageView)

        setupConstraints()
    }

    private func setupConstraints() {
        articleTitle.translatesAutoresizingMaskIntoConstraints = false
        authorName.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        createdTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        postImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            articleTitle.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            articleTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            articleTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),

            authorName.topAnchor.constraint(equalTo: articleTitle.bottomAnchor, constant: 5),
            authorName.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            authorName.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),

            categoryLabel.topAnchor.constraint(equalTo: authorName.bottomAnchor, constant: 5),
            categoryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            categoryLabel.widthAnchor.constraint(equalToConstant: 80),
            categoryLabel.heightAnchor.constraint(equalToConstant: 25),

            createdTimeLabel.centerYAnchor.constraint(equalTo: categoryLabel.centerYAnchor),
            createdTimeLabel.leadingAnchor.constraint(equalTo: categoryLabel.trailingAnchor, constant: 10),

            contentLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 10),
            contentLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            contentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),

            postImageView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 10),
            postImageView.heightAnchor.constraint(equalToConstant: 200),
            postImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            postImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            postImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50)
        ])
    }

    func configure(with imageUrl: String?) {
        if let imageUrl = imageUrl, !imageUrl.isEmpty {
            postImageView.isHidden = false
//            postImageHeightConstraint.isActive = true  // 激活圖片的高度約束
            loadImage(from: imageUrl)
        } else {
            // 沒有圖片 URL，隱藏圖片
            postImageView.isHidden = true
//            postImageHeightConstraint.isActive = false // 移除圖片高度約束
        }
    }

    override func prepareForReuse() {
        articleTitle.text = ""
        authorName.text = ""
        categoryLabel.text = ""
        categoryLabel.backgroundColor = UIColor.lightGray
        createdTimeLabel.text = ""
        contentLabel.text = ""
        postImageView.image = nil
    }

    private func loadImage(from url: String) {
        guard let imageURL = URL(string: url) else {
            print("Invalid URL string")
            return
        }

        URLSession.shared.dataTask(with: imageURL) { data, response, error in
            if let error = error {
                print("Failed to download image: \(error)")
                return
            }

            guard let data = data, let image = UIImage(data: data) else {
                print("Failed to convert data to image")
                return
            }

            DispatchQueue.main.async {
                self.postImageView.image = image
            }
        }.resume()
    }
}
