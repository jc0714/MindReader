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
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "設定"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.textColor = .pink3
        return label
    }()

    private let nameSettingView = SettingItemView(title: "名字設定", icon: UIImage(systemName: "person.fill"))
    private let languageSettingView = SettingItemView(title: "語言選擇", icon: UIImage(systemName: "globe"))
    private let themeSettingView = SettingItemView(title: "主題切換", icon: UIImage(systemName: "paintpalette.fill"))
    private let feedbackView = SettingItemView(title: "回報問題", icon: UIImage(systemName: "exclamationmark.bubble.fill"))

    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(red: 255/255, green: 245/255, blue: 238/255, alpha: 1) // 淡粉色背景
        setupTitleLabel()
        setupContainerStackView()
        addSettingItemsToStackView()
    }

    private func setupTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupContainerStackView() {
        containerStackView.alignment = .center
        view.addSubview(containerStackView)
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            containerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    private func addSettingItemsToStackView() {
        containerStackView.addArrangedSubview(nameSettingView)
        containerStackView.addArrangedSubview(languageSettingView)
        containerStackView.addArrangedSubview(themeSettingView)
        containerStackView.addArrangedSubview(feedbackView)
    }
}

// 自訂可愛風格設定項目 View
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
        stackView.alignment = .center
        addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
}


//class SettingVC: UIViewController {
//
//    // UI 元件
//    let nameTextField: UITextField = {
//        let textField = UITextField()
//        textField.placeholder = "輸入新的姓氏"
//        textField.borderStyle = .roundedRect
//        return textField
//    }()
//
//    let submitButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("送出", for: .normal)
//        button.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
//        return button
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        let userLastName = UserDefaults.standard.string(forKey: "userLastName")
//        nameTextField.text = userLastName
//        
//        setupUI()
//    }
//
//    // 設置 UI
//    func setupUI() {
//        view.backgroundColor = .white
//
//        // 添加 TextField 和 Button
//        view.addSubview(nameTextField)
//        view.addSubview(submitButton)
//
//        // 設置佈局 (這裡簡單地使用 frame)
//        nameTextField.frame = CGRect(x: 20, y: 100, width: view.frame.width - 40, height: 40)
//        submitButton.frame = CGRect(x: 20, y: 160, width: view.frame.width - 40, height: 40)
//    }
//
//    // 送出按鈕的動作
//    @objc func submitButtonTapped() {
//        guard let newName = nameTextField.text, !newName.isEmpty else {
//            print("請輸入新的姓氏")
//            return
//        }
//
//        // 呼叫更新 Firebase 的方法
//        updateNameInFirebase(newName: newName)
//    }
//
//    // 更新 Firebase 中的 name 欄位
//    func updateNameInFirebase(newName: String) {
//        // 假設這裡已經有一個已登入的用戶 ID
//        guard let userId = UserDefaults.standard.string(forKey: "userID") else {
//            print("User ID is nil")
//            return
//        }
//
//        // 更新 Firebase 中的 name 欄位
//        let usersCollection = Firestore.firestore().collection("Users")
//        usersCollection.document(userId).updateData(["name": newName]) { error in
//            if let error = error {
//                print("更新失敗：\(error.localizedDescription)")
//            } else {
//                print("姓名已成功更新")
//
//                // 將新的姓氏存入 UserDefaults
//                UserDefaults.standard.set(newName, forKey: "userLastName")
//                print("新的姓氏已存入 UserDefaults")
//            }
//        }
//    }
//}
