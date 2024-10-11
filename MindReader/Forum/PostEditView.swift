//
//  PostEditView.swift
//  MindReader
//
//  Created by J oyce on 2024/9/15.
//

import UIKit

class PostEditView: UIView {

    var onImageDeleted: (() -> Void)?

    let avatarImage: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .pink3
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "文章主題"
        textField.borderStyle = .roundedRect
        return textField
    }()

    let categoryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        return stackView
    }()

    let contentLabel: UILabel = {
        let label = UILabel()
        label.text = "歡迎分享任何事："
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .pink3
        return label
    }()

    let contentTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.layer.borderColor = UIColor.pink3.cgColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 10
        return textView
    }()

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.pink3.cgColor
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "upload")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    let deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .brown
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.isHidden = true // 預設隱藏
        return button
    }()

    let publishButton: UIButton = {
        let button = UIButton()
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
        setupCategoryButtons()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // Add subviews
        addSubview(avatarImage)
        addSubview(titleTextField)
        addSubview(categoryStackView)
        addSubview(contentLabel)
        addSubview(contentTextView)
        addSubview(imageView)
        imageView.addSubview(deleteButton)
        addSubview(publishButton)

        // Constraints
        avatarImage.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        categoryStackView.translatesAutoresizingMaskIntoConstraints = false
        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        publishButton.translatesAutoresizingMaskIntoConstraints = false

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

            deleteButton.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 8),
            deleteButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -8),
            deleteButton.widthAnchor.constraint(equalToConstant: 20),
            deleteButton.heightAnchor.constraint(equalToConstant: 20),

            publishButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            publishButton.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            publishButton.widthAnchor.constraint(equalToConstant: 150),
            publishButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        deleteButton.addTarget(self, action: #selector(deleteImage), for: .touchUpInside)
    }

    private func setupCategoryButtons() {
        let buttons = [categoryButton1, categoryButton2, categoryButton3, categoryButton4]
        let titles = ["友情", "愛情", "日常", "其他"]
        for (index, button) in buttons.enumerated() {
            button.setTitle(titles[index], for: .normal)
            button.backgroundColor = .pink1
            button.layer.cornerRadius = 15
            button.tintColor = .white
            button.addTarget(self, action: #selector(selectCategory), for: .touchUpInside)
            categoryStackView.addArrangedSubview(button)
        }
    }

    @objc private func selectCategory(_ sender: UIButton) {
        HapticFeedbackManager.lightFeedback()

        selectedCategoryButton?.transform = CGAffineTransform.identity
        selectedCategoryButton?.backgroundColor = .pink1

        // 新選的變樣式
        selectedCategoryButton = sender
        sender.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        sender.backgroundColor = .pink3
        selectedCategory = sender.currentTitle
    }

    @objc private func deleteImage() {
        imageView.image = UIImage(named: "upload")
        deleteButton.isHidden = true
        onImageDeleted?()
    }

    func userDidUploadImage(_ image: UIImage) {
        imageView.image = image
        deleteButton.isHidden = false
    }
}

//class PostEditView: UIView {
//
//    var onImageDeleted: (() -> Void)?
//
//    let avatarImage = UIImageView()
//    let titleTextField = UITextField()
//    let categoryStackView = UIStackView()
//
//    let contentLabel: UILabel = {
//        let label = UILabel()
//        label.text = "歡迎分享任何事："
//        label.font = UIFont.systemFont(ofSize: 18)
//        label.textColor = .pink3
//        return label
//    }()
//
//    let contentTextView = UITextView()
//
//    let imageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFit
//        imageView.layer.borderWidth = 1
//        imageView.layer.borderColor = UIColor.pink3.cgColor
//        imageView.layer.cornerRadius = 10
//        imageView.layer.masksToBounds = true
//        imageView.image = UIImage(named: "upload")
//        imageView.isUserInteractionEnabled = true
//        return imageView
//    }()
//
//    let deleteButton: UIButton = {
//        let button = UIButton()
//        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
//        button.tintColor = .brown
//        button.backgroundColor = .white
//        button.layer.cornerRadius = 10
//        button.layer.masksToBounds = true
//        button.isHidden = true // 預設隱藏
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//
//    let publishButton: UIButton = {
//        let button = UIButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setTitle(" 發佈貼文 ", for: .normal)
//        button.backgroundColor = .pink3
//        button.layer.cornerRadius = 10
//        button.layer.borderWidth = 5
//        button.layer.borderColor = UIColor.milkYellowww.cgColor
//        return button
//    }()
//
//    // Buttons for categories
//    let categoryButton1 = UIButton(type: .system)
//    let categoryButton2 = UIButton(type: .system)
//    let categoryButton3 = UIButton(type: .system)
//    let categoryButton4 = UIButton(type: .system)
//    var selectedCategoryButton: UIButton?
//    var selectedCategory: String?
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupUI()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func setupUI() {
//        let standardMargin = 16
//        let margin = CGFloat(standardMargin / 4)
//
//        avatarImage.backgroundColor = .pink3
//        avatarImage.layer.cornerRadius = 50
//        avatarImage.layer.masksToBounds = true
//        avatarImage.isUserInteractionEnabled = true
//
//        titleTextField.placeholder = "文章主題"
//        titleTextField.borderStyle = .roundedRect
//
//        contentTextView.font = UIFont.systemFont(ofSize: 18)
//        contentTextView.layer.borderColor = UIColor.pink3.cgColor
//        contentTextView.layer.borderWidth = 1.0
//        contentTextView.layer.cornerRadius = 10
//
//        // Setup category buttons
//        categoryButton1.setTitle("友情", for: .normal)
//        categoryButton2.setTitle("愛情", for: .normal)
//        categoryButton3.setTitle("日常", for: .normal)
//        categoryButton4.setTitle("其他", for: .normal)
//        categoryButton1.backgroundColor = .pink1
//        categoryButton2.backgroundColor = .pink1
//        categoryButton3.backgroundColor = .pink1
//        categoryButton4.backgroundColor = .pink1
//        categoryButton1.layer.cornerRadius = 15
//        categoryButton2.layer.cornerRadius = 15
//        categoryButton3.layer.cornerRadius = 15
//        categoryButton4.layer.cornerRadius = 15
//        categoryButton1.tintColor = .white
//        categoryButton2.tintColor = .white
//        categoryButton3.tintColor = .white
//        categoryButton4.tintColor = .white
//        categoryButton1.addTarget(self, action: #selector(selectCategory), for: .touchUpInside)
//        categoryButton2.addTarget(self, action: #selector(selectCategory), for: .touchUpInside)
//        categoryButton3.addTarget(self, action: #selector(selectCategory), for: .touchUpInside)
//        categoryButton4.addTarget(self, action: #selector(selectCategory), for: .touchUpInside)
//
//        categoryStackView.axis = .horizontal
//        categoryStackView.distribution = .fillEqually
//        categoryStackView.spacing = margin
//        categoryStackView.addArrangedSubview(categoryButton1)
//        categoryStackView.addArrangedSubview(categoryButton2)
//        categoryStackView.addArrangedSubview(categoryButton3)
//        categoryStackView.addArrangedSubview(categoryButton4)
//
//        addSubview(avatarImage)
//        addSubview(titleTextField)
//        addSubview(categoryStackView)
//        addSubview(contentLabel)
//        addSubview(contentTextView)
//        addSubview(imageView)
//        imageView.addSubview(deleteButton)
//        addSubview(publishButton)
//
//        avatarImage.translatesAutoresizingMaskIntoConstraints = false
//        titleTextField.translatesAutoresizingMaskIntoConstraints = false
//        categoryStackView.translatesAutoresizingMaskIntoConstraints = false
//        contentTextView.translatesAutoresizingMaskIntoConstraints = false
//        contentLabel.translatesAutoresizingMaskIntoConstraints = false
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            avatarImage.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
//            avatarImage.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
//            avatarImage.heightAnchor.constraint(equalToConstant: 100),
//            avatarImage.widthAnchor.constraint(equalToConstant: 100),
//
//            titleTextField.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
//            titleTextField.leadingAnchor.constraint(equalTo: avatarImage.trailingAnchor, constant: 16),
//            titleTextField.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
//            titleTextField.heightAnchor.constraint(equalToConstant: 50),
//
//            categoryStackView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 15),
//            categoryStackView.leftAnchor.constraint(equalTo: avatarImage.rightAnchor, constant: 20),
//            categoryStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -15),
//            categoryStackView.heightAnchor.constraint(equalToConstant: 40),
//
//            contentLabel.topAnchor.constraint(equalTo: categoryStackView.bottomAnchor, constant: 15),
//            contentLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
//            contentLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -15),
//            contentLabel.heightAnchor.constraint(equalToConstant: 40),
//
//            contentTextView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 5),
//            contentTextView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
//            contentTextView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
//            contentTextView.heightAnchor.constraint(equalToConstant: 200),
//
//            imageView.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 16),
//            imageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
//            imageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
//            imageView.heightAnchor.constraint(equalToConstant: 200),
//
//            deleteButton.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 8),
//            deleteButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -8),
//            deleteButton.widthAnchor.constraint(equalToConstant: 20),
//            deleteButton.heightAnchor.constraint(equalToConstant: 20),
//
//            publishButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
//            publishButton.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
//            publishButton.widthAnchor.constraint(equalToConstant: 150),
//            publishButton.heightAnchor.constraint(equalToConstant: 40)
//        ])
//        deleteButton.addTarget(self, action: #selector(deleteImage), for: .touchUpInside)
//    }
//
//    @objc private func selectCategory(_ sender: UIButton) {
//        HapticFeedbackManager.lightFeedback()
//
//        // 原來選的要變回原樣
//        selectedCategoryButton?.transform = CGAffineTransform.identity
//        selectedCategoryButton?.backgroundColor = .pink1
//
//        // 新選的變樣式
//        selectedCategoryButton = sender
//        sender.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
//        sender.backgroundColor = .pink3
//        selectedCategory = sender.currentTitle
//    }
//
//    @objc private func deleteImage() {
//        imageView.image = UIImage(named: "upload")
//        deleteButton.isHidden = true
//        onImageDeleted?()
//    }
//
//    func userDidUploadImage(_ image: UIImage) {
//        imageView.image = image
//        deleteButton.isHidden = false // 當有圖片時顯示叉叉按鈕
//    }
//}
