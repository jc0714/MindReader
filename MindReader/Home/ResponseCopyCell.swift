//
//  ResponseCell.swift
//  MindReader
//
//  Created by J oyce on 2024/10/3.
//

import Foundation
import UIKit
import AlertKit

class ResponseCopyCell: UITableViewCell {

    private let messageBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 255/255, green: 239/255, blue: 204/255, alpha: 1.0)
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()

    let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()

    private let copyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
        button.tintColor = .systemBrown
        button.isUserInteractionEnabled = true
        return button
    }()

    var messageText: String?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear

        contentView.addSubview(messageBackgroundView)
        messageBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            messageBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            messageBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            messageBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])

        messageBackgroundView.addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: messageBackgroundView.topAnchor, constant: 20),
            messageLabel.leadingAnchor.constraint(equalTo: messageBackgroundView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: messageBackgroundView.trailingAnchor, constant: -50),
            messageLabel.bottomAnchor.constraint(equalTo: messageBackgroundView.bottomAnchor, constant: -20)
        ])

        messageBackgroundView.addSubview(copyButton)
        copyButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            copyButton.trailingAnchor.constraint(equalTo: messageBackgroundView.trailingAnchor, constant: -10),
            copyButton.centerYAnchor.constraint(equalTo: messageBackgroundView.centerYAnchor),
            copyButton.widthAnchor.constraint(equalToConstant: 30),
            copyButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        messageBackgroundView.bringSubviewToFront(copyButton)

        copyButton.addTarget(self, action: #selector(copyMessage), for: .touchUpInside)
    }

    func configure(with message: String) {
        messageLabel.text = message
        messageText = message
    }

    @objc private func copyMessage() {
        guard let text = messageText else { return }

        AlertKitAPI.present(
            title: "複製成功",
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )

        UIPasteboard.general.string = text
        print("Copied to clipboard: \(text)")
    }
}
