//
//  UserInfoCell.swift
//  MindReader
//
//  Created by J oyce on 2024/10/2.
//

import Foundation
import UIKit
import FirebaseFirestore

protocol UserInfoCellDelegate: AnyObject {
    func didTapSubmitButton(newName: String, in cell: UserInfoCell)
}

class UserInfoCell: UITableViewCell {

    weak var delegate: UserInfoCellDelegate?

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 6
        return view
    }()

    private let contentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 40
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView
    }()

    private let randomAvatarLabel: UILabel = {
        let label = UILabel()
        label.text = "頭貼會隨機更換，每次都是小驚喜！"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.brown
        label.textAlignment = .center
        label.alpha = 1.0 // 初始為可見
        return label
    }()

    private let userInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "您的名字："
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .pink3
        return label
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .darkGray
        return label
    }()

    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "輸入新的姓名"
        textField.borderStyle = .roundedRect
        textField.isHidden = true
        return textField
    }()

    private let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "Vector"), for: .normal)
        button.tintColor = .pink3
        button.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        return button
    }()

    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("儲存", for: .normal)
        button.backgroundColor = .pink3
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.isHidden = true
        button.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        showAndHideRandomAvatarLabel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])

        cardView.addSubview(contentImageView)
        contentImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            contentImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            contentImageView.topAnchor.constraint(equalTo: cardView.topAnchor),
            contentImageView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
        ])

        cardView.addSubview(avatarImageView)
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 80),
            avatarImageView.heightAnchor.constraint(equalToConstant: 80)
        ])

        cardView.addSubview(randomAvatarLabel)
        randomAvatarLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            randomAvatarLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 12),
            randomAvatarLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor)
//            randomAvatarLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor)
        ])

        cardView.addSubview(userInfoLabel)
        userInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userInfoLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            userInfoLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor),
            userInfoLabel.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -16)
        ])

        cardView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor, constant: 10)
        ])

        cardView.addSubview(nameTextField)
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameTextField.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            nameTextField.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor, constant: 10),
            nameTextField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -40)
        ])

        cardView.addSubview(editButton)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            editButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            editButton.centerYAnchor.constraint(equalTo: nameTextField.centerYAnchor)
        ])

        cardView.addSubview(submitButton)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            submitButton.centerXAnchor.constraint(equalTo: nameTextField.centerXAnchor),
            submitButton.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 10),
            submitButton.widthAnchor.constraint(equalToConstant: 60),
            submitButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    private func showAndHideRandomAvatarLabel() {
        UIView.animate(withDuration: 1.0, animations: {
            self.randomAvatarLabel.alpha = 1.0 // 顯示 Label
        }, completion: { _ in
            UIView.animate(withDuration: 1.0, delay: 5.0, options: [], animations: {
                self.randomAvatarLabel.alpha = 0.0 // 隱藏 Label
            }, completion: { _ in
                self.randomAvatarLabel.removeFromSuperview() // 移除 Label
            })
        })
    }



    func configure(with title: String, icon: UIImage?) {
        nameLabel.text = title
        avatarImageView.image = icon
    }

    @objc private func editButtonTapped() {
        nameTextField.text = nameLabel.text

        if nameTextField.isHidden {
            nameTextField.isHidden = false
            submitButton.isHidden = false
            nameLabel.isHidden = true
        } else {
            nameTextField.isHidden = true
            submitButton.isHidden = true
            nameLabel.isHidden = false
        }
    }

    @objc private func submitButtonTapped() {
        guard let newName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !newName.isEmpty else { return }
        delegate?.didTapSubmitButton(newName: newName, in: self)
        nameTextField.isHidden = true
        submitButton.isHidden = true
        nameLabel.isHidden = false
    }
}
