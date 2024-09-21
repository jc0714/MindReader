//
//  EditView.swift
//  MindReader
//
//  Created by J oyce on 2024/9/15.
//

import Foundation
import UIKit

class EditView: UIView {

    let avatarImage = UIImageView()
    let titleTextField = UITextField()
    let categoryTextField = UITextField()
    let contentTextView = UITextView()
    let imageView = UIImageView()
    let publishButton = UIButton()

    private let imageNames = ["photo4", "photo5", "photo6", "photo7"]
    var selectedAvatarIndex = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        let standardMargin = 16
        let margin = CGFloat(standardMargin / 4)

        avatarImage.backgroundColor = .pink3
        avatarImage.image = UIImage(named: imageNames[selectedAvatarIndex])
        avatarImage.layer.cornerRadius = 50
        avatarImage.layer.masksToBounds = true
        avatarImage.isUserInteractionEnabled = true

        titleTextField.placeholder = "文章主題"
        categoryTextField.placeholder = "你覺得他是什麼類別？"

        titleTextField.borderStyle = .roundedRect
        categoryTextField.borderStyle = .roundedRect

        contentTextView.font = UIFont.systemFont(ofSize: 18)
        contentTextView.layer.borderColor = UIColor.lightGray.cgColor
        contentTextView.layer.borderWidth = 1.0

        imageView.backgroundColor = .pink1
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit

        publishButton.setTitle("Publish", for: .normal)
        publishButton.backgroundColor = .pink1

        addSubview(avatarImage)
        addSubview(titleTextField)
        addSubview(categoryTextField)
        addSubview(contentTextView)
        addSubview(imageView)
        addSubview(publishButton)

        avatarImage.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        categoryTextField.translatesAutoresizingMaskIntoConstraints = false
        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        publishButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            avatarImage.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: margin),
            avatarImage.leftAnchor.constraint(equalTo: leftAnchor, constant: margin),
            avatarImage.heightAnchor.constraint(equalToConstant: 100),
            avatarImage.widthAnchor.constraint(equalToConstant: 100),

            titleTextField.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: margin),
            titleTextField.leadingAnchor.constraint(equalTo: avatarImage.trailingAnchor, constant: margin),
            titleTextField.rightAnchor.constraint(equalTo: rightAnchor, constant: -margin),
            titleTextField.heightAnchor.constraint(equalToConstant: 50),

            categoryTextField.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: margin),
            categoryTextField.leadingAnchor.constraint(equalTo: avatarImage.trailingAnchor, constant: margin),
            categoryTextField.rightAnchor.constraint(equalTo: rightAnchor, constant: -margin),
            categoryTextField.heightAnchor.constraint(equalToConstant: 50),

            contentTextView.topAnchor.constraint(equalTo: categoryTextField.bottomAnchor, constant: margin),
            contentTextView.leftAnchor.constraint(equalTo: leftAnchor, constant: margin),
            contentTextView.rightAnchor.constraint(equalTo: rightAnchor, constant: -margin),
            contentTextView.heightAnchor.constraint(equalToConstant: 200),

            imageView.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: margin),
            imageView.leftAnchor.constraint(equalTo: leftAnchor, constant: margin),
            imageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -margin),
            imageView.heightAnchor.constraint(equalToConstant: 200),

            publishButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: margin),
            publishButton.leftAnchor.constraint(equalTo: leftAnchor, constant: margin),
            publishButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -margin),
            publishButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(changeAvatar))
        avatarImage.addGestureRecognizer(tapGesture)
    }

    @objc func changeAvatar() {
        selectedAvatarIndex = (selectedAvatarIndex + 1) % imageNames.count
        avatarImage.image = UIImage(named: imageNames[selectedAvatarIndex])
    }
}
