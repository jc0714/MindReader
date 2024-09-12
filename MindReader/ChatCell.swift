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

    var leadingConstraint: NSLayoutConstraint!
    var trailingConstraint: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addSubview(bubbleBackgroundView)
        addSubview(messageLabel)

        let constraints = [
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250),

            bubbleBackgroundView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -8),
            bubbleBackgroundView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -16),
            bubbleBackgroundView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 8),
            bubbleBackgroundView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 16)
        ]
        NSLayoutConstraint.activate(constraints)

        leadingConstraint = messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32)
        trailingConstraint = messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with message: String, isIncoming: Bool) {
        messageLabel.text = message

        leadingConstraint.isActive = false
        trailingConstraint.isActive = false

        if isIncoming {
            leadingConstraint.isActive = true
            bubbleBackgroundView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        } else {
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



//        // Define the constraints
//        let constraints = [
//            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
//            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
//            messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
//
//            bubbleBackgroundView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -8),
//            bubbleBackgroundView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -16),
//            bubbleBackgroundView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 8),
//            bubbleBackgroundView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 16),
//            bubbleBackgroundView.widthAnchor.constraint(equalTo: messageLabel.widthAnchor, constant: 32)
//        ]
//
//        // Activate the constraints
//        NSLayoutConstraint.activate(constraints)
//
//        // Define and activate leading and trailing constraints if necessary
//        leadingConstraint = messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32)
//        trailingConstraint = messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
//        NSLayoutConstraint.activate([leadingConstraint, trailingConstraint])
