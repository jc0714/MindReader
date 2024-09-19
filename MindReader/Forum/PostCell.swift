//
//  PostCell.swift
//  MindReader
//
//  Created by J oyce on 2024/9/15.
//

import Foundation
import UIKit

class PostCell: UITableViewCell {

    private var isHeartSelected: Bool = false

    var commentButtonTappedClosure: (() -> Void)?
    var commentButtonLongPressClosure: (() -> Void)?

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
        label.backgroundColor = .pink2
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
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {

        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true

        heartButton.isUserInteractionEnabled = true

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

        NSLayoutConstraint.activate([
            articleTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            articleTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            articleTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),

            authorName.topAnchor.constraint(equalTo: articleTitle.bottomAnchor, constant: 5),
            authorName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            authorName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),

            categoryLabel.topAnchor.constraint(equalTo: authorName.bottomAnchor, constant: 5),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            categoryLabel.widthAnchor.constraint(equalToConstant: 80),
            categoryLabel.heightAnchor.constraint(equalToConstant: 25),

            createdTimeLabel.centerYAnchor.constraint(equalTo: categoryLabel.centerYAnchor),
            createdTimeLabel.leadingAnchor.constraint(equalTo: categoryLabel.trailingAnchor, constant: 10),

            contentLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 10),
            contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),

            postImageView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 10),
            postImageView.heightAnchor.constraint(equalToConstant: 200),
            postImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            postImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            postImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -80),

            heartView.heightAnchor.constraint(equalToConstant: 50),
            heartView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            heartView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),

            commentView.heightAnchor.constraint(equalToConstant: 50),
            commentView.leadingAnchor.constraint(equalTo: heartView.trailingAnchor, constant: 30),
            commentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15)
        ])
        heartButton.addTarget(self, action: #selector(heartButtonTapped), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(commentButtonTapped), for: .touchUpInside)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        commentButton.addGestureRecognizer(longPressGesture)
    }

    func configure(with imageUrl: String?) {
        if let imageUrl = imageUrl, !imageUrl.isEmpty {
            postImageView.isHidden = false
//            postImageHeightConstraint.isActive = true
            loadImage(from: imageUrl)
        } else {
            // 沒有圖片 URL，隱藏圖片
            postImageView.isHidden = true
//            postImageHeightConstraint.isActive = false
        }
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
        URLSession.shared.dataTask(with: imageURL) { data, _, error in
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

    private func updateHeartButtonImage() {
        let symbolName = isHeartSelected ? "heart.fill" : "heart"
        heartButton.setImage((UIImage(systemName: symbolName)), for: .normal)
    }

    @objc func heartButtonTapped() {
        isHeartSelected.toggle()
        updateHeartButtonImage()
    }

    @objc private func commentButtonTapped() {
        commentButtonTappedClosure?()
    }

    @objc private func handleLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            commentButtonLongPressClosure?()
        }
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
