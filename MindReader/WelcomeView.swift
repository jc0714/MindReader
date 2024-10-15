//
//  WelcomeView.swift
//  MindReader
//
//  Created by J oyce on 2024/10/15.
//

import Foundation
import UIKit

class WelcomeView: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "請輸入你的名字："
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .brown
        label.textAlignment = .center
        return label
    }()

    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "你的名字"
        textField.borderStyle = .none
        textField.backgroundColor = UIColor.brown.withAlphaComponent(0.1)
        textField.layer.cornerRadius = 8 // 圓角
        textField.layer.borderWidth = 1.0 // 邊框寬度
        textField.layer.borderColor = UIColor.brown.withAlphaComponent(0.5).cgColor // 邊框顏色與 label 字體一致
        textField.setLeftPaddingPoints(10) // 左邊內邊距
        textField.font = UIFont.systemFont(ofSize: 18) // 與 titleLabel 字體一致
        textField.textColor = .brown // 文本顏色與 label 一致
        return textField
    }()

    let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("送出", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = UIColor.brown.withAlphaComponent(0.8)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()

    private let cloudImageView: UIImageView = {
        let imageView = UIImageView()
        let cloudImage = UIImage(systemName: "cloud.fill")
        imageView.image = cloudImage
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        addSubview(cloudImageView)
        cloudImageView.translatesAutoresizingMaskIntoConstraints = false

        // 添加輸入框和按鈕
        addSubview(titleLabel)
        addSubview(nameTextField)
        addSubview(confirmButton)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.translatesAutoresizingMaskIntoConstraints = false

        // 設置約束
        NSLayoutConstraint.activate([
            cloudImageView.topAnchor.constraint(equalTo: self.topAnchor),
            cloudImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            cloudImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            cloudImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: cloudImageView.topAnchor, constant: 70),
            titleLabel.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor, constant: 0),

            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            nameTextField.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            nameTextField.widthAnchor.constraint(equalToConstant: 180),
            nameTextField.heightAnchor.constraint(equalToConstant: 50),

            confirmButton.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            confirmButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            confirmButton.widthAnchor.constraint(equalToConstant: 80),
            confirmButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
