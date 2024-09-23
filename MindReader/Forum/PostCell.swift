//
//  PostCell.swift
//  MindReader
//
//  Created by J oyce on 2024/9/15.
//

import Foundation
import UIKit
import Kingfisher

class PostCell: UITableViewCell {

    private var isHeartSelected: Bool = false

    var heartButtonTappedClosure: (() -> Void)?

    var commentButtonTappedClosure: (() -> Void)?
    var commentButtonLongPressClosure: (() -> Void)?

    var authorTapAction: (() -> Void)?

    var postImageHeightConstraint: NSLayoutConstraint!

    let avatarImageView = UIImageView()

    let articleTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 20)
        label.backgroundColor = .pink3
        return label
    }()

    let authorName: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .pink1
        return label
    }()

    let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.backgroundColor = .color
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

    let heartButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .red
        return button
    }()

    let heartCount: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .red
        return label
    }()

    let commentButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "bubble"), for: .normal)
        button.tintColor = .systemMint
        return button
    }()

    let commentCount: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .systemMint
        return label
    }()

    lazy var commentView: UIView = {
        return createStackedView(button: commentButton, label: commentCount)
    }()

    lazy var heartView: UIView = {
        return createStackedView(button: heartButton, label: heartCount)
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(authorTapped))
        authorName.addGestureRecognizer(tapGesture)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {

        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 35

        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true

        heartButton.isUserInteractionEnabled = true

        contentView.addSubview(avatarImageView)
        contentView.addSubview(articleTitle)
        contentView.addSubview(authorName)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(createdTimeLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(postImageView)
        contentView.addSubview(heartButton)
        contentView.addSubview(heartView)
        contentView.addSubview(commentView)

        setupConstraints()
    }

    private func setupConstraints() {
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        articleTitle.translatesAutoresizingMaskIntoConstraints = false
        authorName.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        createdTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        postImageView.translatesAutoresizingMaskIntoConstraints = false
        heartButton.translatesAutoresizingMaskIntoConstraints = false
        commentButton.translatesAutoresizingMaskIntoConstraints = false
        heartView.translatesAutoresizingMaskIntoConstraints = false
        commentView.translatesAutoresizingMaskIntoConstraints = false

        postImageHeightConstraint = postImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 300)
        postImageHeightConstraint.isActive = true

        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),

            articleTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            articleTitle.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 15),
            articleTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),

            authorName.topAnchor.constraint(equalTo: articleTitle.bottomAnchor, constant: 5),
            authorName.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 15),
            authorName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),

            categoryLabel.topAnchor.constraint(equalTo: authorName.bottomAnchor, constant: 5),
            categoryLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 15),
            categoryLabel.widthAnchor.constraint(equalToConstant: 80),
            categoryLabel.heightAnchor.constraint(equalToConstant: 25),

            createdTimeLabel.centerYAnchor.constraint(equalTo: categoryLabel.centerYAnchor),
            createdTimeLabel.leadingAnchor.constraint(equalTo: categoryLabel.trailingAnchor, constant: 10),

            contentLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 15),
            contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),

            postImageView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 10),
            postImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            postImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            postImageView.bottomAnchor.constraint(equalTo: heartView.topAnchor, constant: -10),

            heartView.heightAnchor.constraint(equalToConstant: 50),
            heartView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            heartView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),

            commentView.heightAnchor.constraint(equalToConstant: 50),
            commentView.leadingAnchor.constraint(equalTo: heartView.trailingAnchor, constant: 30),
            commentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15)
        ])

        postImageHeightConstraint.isActive = false

        heartButton.addTarget(self, action: #selector(heartButtonTapped), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(commentButtonTapped), for: .touchUpInside)
    }

    func configure(with imageUrl: String?) {
        if let imageUrl = imageUrl, !imageUrl.isEmpty {
            postImageView.isHidden = false
            postImageHeightConstraint.isActive = true
            loadImage(from: imageUrl)
        } else {
            postImageView.isHidden = true
            postImageHeightConstraint.isActive = false
        }
        setNeedsLayout()
        layoutIfNeeded()
    }

    override func prepareForReuse() {
        articleTitle.text = ""
        authorName.text = ""
        categoryLabel.text = ""
        categoryLabel.backgroundColor = .color
        createdTimeLabel.text = ""
        contentLabel.text = ""
        postImageView.image = nil
        isHeartSelected = false
    }

    private func loadImage(from url: String) {
        guard let imageURL = URL(string: url) else {
            print("Invalid URL string")
            return
        }

        // 使用 Kingfisher 加載圖片，無需 placeholder
        postImageView.kf.setImage(with: imageURL, options: [
            .transition(.fade(0.2)), // 圖片加載時淡入效果
            .cacheOriginalImage      // 自動緩存圖片
        ])
    }

    @objc func heartButtonTapped() {
        // 通知 VC
        heartButtonTappedClosure?()
    }

    @objc private func commentButtonTapped() {
        // 通知 VC
        commentButtonTappedClosure?()
    }

    @objc private func authorTapped() {
        authorTapAction?()
    }

    func createStackedView(button: UIButton, label: UILabel) -> UIView {
        let view = UIView()
        let stackView = UIStackView(arrangedSubviews: [button, label])
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.alignment = .center

        view.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        return view
    }
}
