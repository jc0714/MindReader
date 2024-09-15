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
        label.font = UIFont.systemFont(ofSize: 18)
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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        addSubview(articleTitle)
        addSubview(authorName)
        addSubview(categoryLabel)
        addSubview(createdTimeLabel)
        addSubview(contentLabel)

        setupConstraints()
    }

    private func setupConstraints() {
        articleTitle.translatesAutoresizingMaskIntoConstraints = false
        authorName.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        createdTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false

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
            contentLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }

    override func prepareForReuse() {
        articleTitle.text = ""
        authorName.text = ""
        categoryLabel.text = ""
        categoryLabel.backgroundColor = UIColor.lightGray
        createdTimeLabel.text = ""
        contentLabel.text = ""
    }
}
