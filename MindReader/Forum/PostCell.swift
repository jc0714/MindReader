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

    private let imageNames = ["avatar1", "avatar2", "avatar3", "avatar4", "avatar5", "avatar6", "avatar7", "avatar8"]
    private var isHeartSelected: Bool = false

    var heartButtonTappedClosure: (() -> Void)?
    var commentButtonTappedClosure: (() -> Void)?
    var reportButtonTappedClosure: ((String) -> Void)?

    var postImageHeightConstraint: NSLayoutConstraint!

    let avatarImageView = UIImageView()

    let articleTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()

    let authorName: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemBrown
        label.isUserInteractionEnabled = true
        return label
    }()

    let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.backgroundColor = .milkYellow
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        return label
    }()

    let createdTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        return label
    }()

    let contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = .black
        return label
    }()

    let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    let heartButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .orange
        button.backgroundColor = .white
        return button
    }()

    let heartCount: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .orange
        return label
    }()

    let commentButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "bubble"), for: .normal)
        button.tintColor = .brown
        return button
    }()

    let commentCount: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .brown
        return label
    }()

    lazy var commentView: UIView = {
        return createStackedView(button: commentButton, label: commentCount)
    }()

    lazy var heartView: UIView = {
        return createStackedView(button: heartButton, label: heartCount)
    }()

    let reportButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        return button
    }()

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(cardView)
        cardView.addSubview(reportButton)
        cardView.addSubview(avatarImageView)
        cardView.addSubview(articleTitle)
        cardView.addSubview(authorName)
        cardView.addSubview(categoryLabel)
        cardView.addSubview(createdTimeLabel)
        cardView.addSubview(contentLabel)
        cardView.addSubview(postImageView)
        cardView.addSubview(heartView)
        cardView.addSubview(commentView)

        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 35

        heartButton.isUserInteractionEnabled = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showFullScreenImage))
        postImageView.addGestureRecognizer(tapGesture)

        setupConstraints()
        setupReportMenu()
    }

    private func setupReportMenu() {
        let reportAction = UIAction(title: "檢舉", image: UIImage(systemName: "exclamationmark.bubble")) { _ in
            self.reportButtonTappedClosure?("檢舉")
        }

        let blockAction = UIAction(title: "封鎖", image: UIImage(systemName: "hand.raised")) { _ in
            self.reportButtonTappedClosure?("封鎖")
        }

        let menu = UIMenu(title: "", children: [reportAction, blockAction])
        reportButton.menu = menu
        reportButton.showsMenuAsPrimaryAction = true
    }

    private func setupConstraints() {
        cardView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        articleTitle.translatesAutoresizingMaskIntoConstraints = false
        authorName.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        createdTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        postImageView.translatesAutoresizingMaskIntoConstraints = false
        heartView.translatesAutoresizingMaskIntoConstraints = false
        commentView.translatesAutoresizingMaskIntoConstraints = false
        reportButton.translatesAutoresizingMaskIntoConstraints = false

        postImageHeightConstraint = postImageView.heightAnchor.constraint(equalToConstant: 300)
        postImageHeightConstraint.isActive = true

        NSLayoutConstraint.activate([

            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

            reportButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),
            reportButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),

            avatarImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 15),
            avatarImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 15),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),

            articleTitle.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),
            articleTitle.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 15),
            articleTitle.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -15),

            authorName.topAnchor.constraint(equalTo: articleTitle.bottomAnchor, constant: 5),
            authorName.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 15),
            authorName.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -15),

            categoryLabel.topAnchor.constraint(equalTo: authorName.bottomAnchor, constant: 5),
            categoryLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 15),
            categoryLabel.widthAnchor.constraint(equalToConstant: 60),
            categoryLabel.heightAnchor.constraint(equalToConstant: 25),

            createdTimeLabel.bottomAnchor.constraint(equalTo: categoryLabel.bottomAnchor),
            createdTimeLabel.leadingAnchor.constraint(equalTo: categoryLabel.trailingAnchor, constant: 10),

            contentLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 15),
            contentLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 30),
            contentLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -30),

            postImageView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 10),
            postImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 30),
            postImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -30),
            postImageView.bottomAnchor.constraint(equalTo: heartView.topAnchor, constant: -10),

            heartView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 30),
            heartView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -15),

            commentView.leadingAnchor.constraint(equalTo: heartView.trailingAnchor, constant: 30),
            commentView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -15)
        ])

        heartButton.addTarget(self, action: #selector(heartButtonTapped), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(commentButtonTapped), for: .touchUpInside)
    }

    func configure(with post: Post, imageUrl: String?) {
        avatarImageView.image = UIImage(named: imageNames[post.avatar])
        articleTitle.text = post.title
        authorName.text = post.author.name
        createdTimeLabel.text = post.createdTime
        categoryLabel.text = post.category
        contentLabel.text = post.content
        heartCount.text = String(post.like)
        commentCount.text = String(post.comment)

        if let imageUrl = imageUrl, !imageUrl.isEmpty {
            postImageView.isHidden = false
            postImageHeightConstraint.isActive = true
            loadImage(from: imageUrl)
        } else {
            postImageView.isHidden = true
            postImageHeightConstraint.isActive = false
        }
        layoutIfNeeded()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        articleTitle.text = ""
        authorName.text = ""
        categoryLabel.text = ""
        categoryLabel.backgroundColor = .milkYellow
        createdTimeLabel.text = ""
        contentLabel.text = ""
        postImageView.image = nil
        isHeartSelected = false
        postImageView.isHidden = true
        backgroundColor = nil
    }

    private func loadImage(from url: String) {
        guard let imageURL = URL(string: url) else {
            print("Invalid URL string")
            return
        }

        postImageView.kf.setImage(with: imageURL, options: [
            .transition(.fade(0.2)),
            .cacheOriginalImage
        ]) { [weak self] result in
            switch result {
            case .success(_):
                self?.setNeedsLayout()
                self?.layoutIfNeeded()
            case .failure(let error):
                print("Image load failed: \(error)")
            }
        }
    }

    @objc private func heartButtonTapped() {
        AnimationUtility.playHeartAnimation(above: heartButton)
        HapticFeedbackManager.lightFeedback()
        heartButtonTappedClosure?()
    }

    @objc private func commentButtonTapped() {
        HapticFeedbackManager.lightFeedback()
        commentButtonTappedClosure?()
    }

    private func createStackedView(button: UIButton, label: UILabel) -> UIView {
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

extension PostCell: UIScrollViewDelegate {
    @objc private func showFullScreenImage() {
        guard let image = postImageView.image else { return }

        let fullScreenView = UIView(frame: UIScreen.main.bounds)
        fullScreenView.backgroundColor = .black
        fullScreenView.alpha = 0.0

        let scrollView = UIScrollView(frame: fullScreenView.bounds)
        scrollView.backgroundColor = .black
        scrollView.maximumZoomScale = 3.0
        scrollView.minimumZoomScale = 1.0
        scrollView.delegate = self

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = scrollView.bounds
        scrollView.addSubview(imageView)

        let closeButton = UIButton(frame: CGRect(x: fullScreenView.bounds.width - 50, y: 50, width: 30, height: 30))
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .white
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.5) // 半透明黑色背景
        closeButton.layer.cornerRadius = 15 // 圓角，與按鈕寬高一致
        closeButton.addTarget(self, action: #selector(dismissFullScreenView(_:)), for: .touchUpInside)

        fullScreenView.addSubview(scrollView)
        fullScreenView.addSubview(closeButton)

        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissFullScreenView(_:)))
        swipeGesture.direction = .down
        fullScreenView.addGestureRecognizer(swipeGesture)

        // 加到視圖上
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.addSubview(fullScreenView)
            UIView.animate(withDuration: 0.3) {
                fullScreenView.alpha = 1.0
            }
        }
    }

    @objc private func dismissFullScreenView(_ sender: Any) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }

        if let fullScreenView = window.subviews.last {
            UIView.animate(withDuration: 0.3, animations: {
                fullScreenView.alpha = 0.0
            }, completion: { _ in
                fullScreenView.removeFromSuperview()
            })
        }
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews.first
    }
}
