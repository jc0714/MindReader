//
//  ChatCell.swift
//  MindReader
//
//  Created by J oyce on 2024/9/11.
//

import Foundation
import UIKit
import AlertKit

class ChatCell: UITableViewCell {

    let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let bubbleBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.9, alpha: 1)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let inComeMsgImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let readLabel: UILabel = {
        let label = UILabel()
        label.text = "Reed"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var messageLeadingConstraint: NSLayoutConstraint!
    var messageTrailingConstraint: NSLayoutConstraint!
    var avatarLeadingConstraint: NSLayoutConstraint!

    var timeLeadingConstraint: NSLayoutConstraint!
    var timeTrailingConstraint: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        addLongPressGesture()
    }

    func setupViews() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        addSubview(bubbleBackgroundView)
        addSubview(messageLabel)
        addSubview(readLabel)
        addSubview(timeLabel)
        addSubview(inComeMsgImageView) // 添加頭貼

        let constraints = [
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250),

            bubbleBackgroundView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -8),
            bubbleBackgroundView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -16),
            bubbleBackgroundView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 8),
            bubbleBackgroundView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 16),

            readLabel.trailingAnchor.constraint(equalTo: bubbleBackgroundView.leadingAnchor, constant: -8),
            readLabel.bottomAnchor.constraint(equalTo: bubbleBackgroundView.bottomAnchor, constant: -14),

            timeLabel.bottomAnchor.constraint(equalTo: bubbleBackgroundView.bottomAnchor),

            inComeMsgImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            inComeMsgImageView.bottomAnchor.constraint(equalTo: bubbleBackgroundView.bottomAnchor, constant: -4),
            inComeMsgImageView.widthAnchor.constraint(equalToConstant: 40),
            inComeMsgImageView.heightAnchor.constraint(equalToConstant: 40)
        ]
        NSLayoutConstraint.activate(constraints)

        // 自己
        messageTrailingConstraint = messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
        timeLeadingConstraint = timeLabel.trailingAnchor.constraint(equalTo: bubbleBackgroundView.leadingAnchor, constant: -8)

        // 對方
        messageLeadingConstraint = messageLabel.leadingAnchor.constraint(equalTo: inComeMsgImageView.trailingAnchor, constant: 24)
        timeTrailingConstraint = timeLabel.leadingAnchor.constraint(equalTo: bubbleBackgroundView.trailingAnchor, constant: 8)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addLongPressGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        self.addGestureRecognizer(longPressGesture)
    }

    @objc private func handleLongPress() {
        UIPasteboard.general.string = messageLabel.text
        print("Message copied: \(messageLabel.text ?? "")")

        AlertKitAPI.present(
            title: "複製成功",
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
    }

    func configure(with message: String, time: String, isIncoming: Bool) {
        messageLabel.text = message
        timeLabel.text = time

        timeTrailingConstraint.isActive = false
        timeLeadingConstraint.isActive = false

        messageLeadingConstraint.isActive = false
        messageTrailingConstraint.isActive = false

        // 對方的訊息
        if isIncoming {
            readLabel.text = nil
            messageLeadingConstraint.isActive = true
            timeTrailingConstraint.isActive = true
            bubbleBackgroundView.backgroundColor = .yelloww.withAlphaComponent(0.5)

            inComeMsgImageView.isHidden = false
            inComeMsgImageView.image = UIImage(named: "photo4")
        } else {
            readLabel.text = "Read"
            messageTrailingConstraint.isActive = true
            timeLeadingConstraint.isActive = true
            bubbleBackgroundView.backgroundColor = UIColor.brown
            messageLabel.textColor = .white

            inComeMsgImageView.isHidden = true
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.textColor = .black
        inComeMsgImageView.isHidden = true // 重置頭貼狀態
    }
}

