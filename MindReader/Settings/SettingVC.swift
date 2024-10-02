//
//  SettingVC.swift
//  MindReader
//
//  Created by J oyce on 2024/9/26.
//

import Foundation
import UIKit
import Firebase

class SettingVC: UIViewController {

    // UI 元素
    private let titleLabel = createLabel(text: "設定", fontSize: 24, fontWeight: .bold, textColor: .pink3)
    private let nameLabel = createLabel(text: "名字", fontSize: 18, fontWeight: .medium, textColor: .darkGray)

    private let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "pencil"), for: .normal)
        button.tintColor = .pink3
        button.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        return button
    }()

    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "輸入新的姓名"
        textField.borderStyle = .roundedRect
        textField.isHidden = true
        return textField
    }()

    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("送出", for: .normal)
        button.backgroundColor = .pink3
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.isHidden = true
        button.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        return button
    }()

    private let containerStackView = UIStackView()

    // 新增主題切換和回報問題的設定項
    private let themeSettingView = SettingItemView(title: "主題切換", icon: UIImage(systemName: "paintpalette.fill"))
    private let feedbackView = SettingItemView(title: "回報問題", icon: UIImage(systemName: "exclamationmark.bubble.fill"))
    private let logOutView = SettingItemView(title: "登出", icon: UIImage(systemName: "heart.fill"))

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserName()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(red: 255/255, green: 245/255, blue: 238/255, alpha: 1)

        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        containerStackView.axis = .vertical
        containerStackView.spacing = 16
        containerStackView.distribution = .equalSpacing

        containerStackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(containerStackView)
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            containerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        addSettingItemsToStackView()
    }

    private func addSettingItemsToStackView() {
        // 姓名設定區塊
        let nameSettingView = UIStackView(arrangedSubviews: [nameLabel, editButton])
        nameSettingView.axis = .horizontal
        nameSettingView.spacing = 8
        nameSettingView.alignment = .center

        logOutView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(logOutTapped))
        logOutView.addGestureRecognizer(tapGesture)

        containerStackView.addArrangedSubview(nameSettingView)
        containerStackView.addArrangedSubview(nameTextField)
        containerStackView.addArrangedSubview(submitButton)
        containerStackView.addArrangedSubview(themeSettingView)
        containerStackView.addArrangedSubview(feedbackView)
        containerStackView.addArrangedSubview(logOutView)
    }


    private func loadUserName() {
        let userLastName = UserDefaults.standard.string(forKey: "userLastName")
        nameLabel.text = userLastName
    }

    @objc private func logOutTapped() {
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")

        print("登出!!!")
    }

    @objc private func editButtonTapped() {
        nameTextField.text = nameLabel.text

        if nameTextField.isHidden == false{
            nameTextField.isHidden = true
            submitButton.isHidden = true
        } else {
            nameTextField.isHidden = false
            submitButton.isHidden = false
        }
    }

    @objc private func submitButtonTapped() {
        guard let newName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !newName.isEmpty else { return }
        updateNameInFirebase(newName: newName)
    }

    private func updateNameInFirebase(newName: String) {
        guard let userId = UserDefaults.standard.string(forKey: "userID") else { return }

        let usersCollection = Firestore.firestore().collection("Users")
        usersCollection.document(userId).updateData(["userFullName": newName]) { error in
            if error == nil {
                UserDefaults.standard.set(newName, forKey: "userLastName")
                self.nameLabel.text = newName
                self.nameTextField.isHidden = true
                self.submitButton.isHidden = true
            }
        }
    }

    private static func createLabel(text: String, fontSize: CGFloat, fontWeight: UIFont.Weight, textColor: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        label.textColor = textColor
        return label
    }
}

class SettingItemView: UIView {

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .pink3
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .darkGray
        return label
    }()

    init(title: String, icon: UIImage?) {
        super.init(frame: .zero)
        titleLabel.text = title
        iconImageView.image = icon
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 15
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4

        let stackView = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .leading
        addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.widthAnchor.constraint(equalToConstant: 200),
//            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
}
