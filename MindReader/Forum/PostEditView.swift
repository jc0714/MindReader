//
//  EditView.swift
//  MindReader
//
//  Created by J oyce on 2024/9/15.
//

import UIKit

class PostEditView: UIView {

    let avatarImage = UIImageView()
    let titleTextField = UITextField()
    let categoryStackView = UIStackView()

    let contentLabel: UILabel = {
        let label = UILabel()
        label.text = "歡迎分享任何事："
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .pink3
        return label
    }()

    let contentTextView = UITextView()

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.pink1.cgColor
        imageView.layer.cornerRadius = 10
        imageView.image = UIImage(named: "uploadImage")
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

//    let publishButton = UIButton()
    let publishButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(" 發佈貼文 ", for: .normal)
        button.backgroundColor = .pink3
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.milkYellowww.cgColor
        return button
    }()

    // Buttons for categories
    let categoryButton1 = UIButton(type: .system)
    let categoryButton2 = UIButton(type: .system)
    let categoryButton3 = UIButton(type: .system)
    let categoryButton4 = UIButton(type: .system)
    var selectedCategoryButton: UIButton?
    var selectedCategory: String?

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
        avatarImage.layer.cornerRadius = 50
        avatarImage.layer.masksToBounds = true
        avatarImage.isUserInteractionEnabled = true

        titleTextField.placeholder = "文章主題"
        titleTextField.borderStyle = .roundedRect

        contentTextView.font = UIFont.systemFont(ofSize: 18)
        contentTextView.layer.borderColor = UIColor.pink3.cgColor
        contentTextView.layer.borderWidth = 1.0
        contentTextView.layer.cornerRadius = 10

        // Setup category buttons
        categoryButton1.setTitle("友情", for: .normal)
        categoryButton2.setTitle("愛情", for: .normal)
        categoryButton3.setTitle("日常", for: .normal)
        categoryButton4.setTitle("其他", for: .normal)
        categoryButton1.backgroundColor = .pink1
        categoryButton2.backgroundColor = .pink1
        categoryButton3.backgroundColor = .pink1
        categoryButton4.backgroundColor = .pink1
        categoryButton1.layer.cornerRadius = 15
        categoryButton2.layer.cornerRadius = 15
        categoryButton3.layer.cornerRadius = 15
        categoryButton4.layer.cornerRadius = 15
        categoryButton1.tintColor = .white
        categoryButton2.tintColor = .white
        categoryButton3.tintColor = .white
        categoryButton4.tintColor = .white
        categoryButton1.addTarget(self, action: #selector(selectCategory), for: .touchUpInside)
        categoryButton2.addTarget(self, action: #selector(selectCategory), for: .touchUpInside)
        categoryButton3.addTarget(self, action: #selector(selectCategory), for: .touchUpInside)
        categoryButton4.addTarget(self, action: #selector(selectCategory), for: .touchUpInside)

        categoryStackView.axis = .horizontal
        categoryStackView.distribution = .fillEqually
        categoryStackView.spacing = margin
        categoryStackView.addArrangedSubview(categoryButton1)
        categoryStackView.addArrangedSubview(categoryButton2)
        categoryStackView.addArrangedSubview(categoryButton3)
        categoryStackView.addArrangedSubview(categoryButton4)

        addSubview(avatarImage)
        addSubview(titleTextField)
        addSubview(categoryStackView)
        addSubview(contentLabel)
        addSubview(contentTextView)
        addSubview(imageView)
        addSubview(publishButton)

        avatarImage.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        categoryStackView.translatesAutoresizingMaskIntoConstraints = false
        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            avatarImage.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            avatarImage.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            avatarImage.heightAnchor.constraint(equalToConstant: 100),
            avatarImage.widthAnchor.constraint(equalToConstant: 100),

            titleTextField.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            titleTextField.leadingAnchor.constraint(equalTo: avatarImage.trailingAnchor, constant: 16),
            titleTextField.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 50),

            categoryStackView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 15),
            categoryStackView.leftAnchor.constraint(equalTo: avatarImage.rightAnchor, constant: 20),
            categoryStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -15),
            categoryStackView.heightAnchor.constraint(equalToConstant: 40),

            contentLabel.topAnchor.constraint(equalTo: categoryStackView.bottomAnchor, constant: 15),
            contentLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            contentLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -15),
            contentLabel.heightAnchor.constraint(equalToConstant: 40),

            contentTextView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 5),
            contentTextView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            contentTextView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            contentTextView.heightAnchor.constraint(equalToConstant: 200),

            imageView.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 16),
            imageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            imageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalToConstant: 200),

            publishButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            publishButton.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            publishButton.widthAnchor.constraint(equalToConstant: 150),
            publishButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc private func selectCategory(_ sender: UIButton) {
        HapticFeedbackManager.successFeedback()

        // 原來選的要變回原樣
        selectedCategoryButton?.transform = CGAffineTransform.identity
        selectedCategoryButton?.backgroundColor = .pink1

        // 新選的變樣式
        selectedCategoryButton = sender
        sender.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        sender.backgroundColor = .pink3
        selectedCategory = sender.currentTitle
    }
}
