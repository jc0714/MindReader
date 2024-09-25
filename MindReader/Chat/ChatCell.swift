//
//  ChatCell.swift
//  MindReader
//
//  Created by J oyce on 2024/9/11.
//

import Foundation
import UIKit

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

    var leadingConstraint: NSLayoutConstraint!
    var trailingConstraint: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addSubview(bubbleBackgroundView)
        addSubview(messageLabel)
        addSubview(readLabel)
        addSubview(timeLabel)

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

            timeLabel.trailingAnchor.constraint(equalTo: bubbleBackgroundView.leadingAnchor, constant: -8),
            timeLabel.bottomAnchor.constraint(equalTo: bubbleBackgroundView.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)

        leadingConstraint = messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32)
        trailingConstraint = messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with message: String, time: String, isIncoming: Bool) {
        messageLabel.text = message

        leadingConstraint.isActive = false
        trailingConstraint.isActive = false

        // 對方的訊息
        if isIncoming {
            readLabel.text = nil
            timeLabel.text = nil
            leadingConstraint.isActive = true
            bubbleBackgroundView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        } else {
            readLabel.text = "Read"
            timeLabel.text = time
            trailingConstraint.isActive = true
            bubbleBackgroundView.backgroundColor = UIColor.black
            messageLabel.textColor = .white
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.textColor = .black
    }
}
