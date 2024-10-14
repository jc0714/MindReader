//
//  TextAdjustmentVC.swift
//  MindReader
//
//  Created by J oyce on 2024/10/14.
//

import Foundation
import UIKit

class TextAdjustmentVC: UIViewController {
    var copiedText: String?
    var onConfirm: ((String) -> Void)?

    // 新增標籤
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "早安圖文字"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = UIColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1) // 類似附圖的棕色
        return label
    }()

    private let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18) // 調整字體大小
        textView.textColor = UIColor(red: 0.4, green: 0.3, blue: 0.2, alpha: 1) // 類似附圖的顏色
        textView.backgroundColor = UIColor(red: 1, green: 0.95, blue: 0.85, alpha: 1) // 輕微米黃色背景
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.brown.cgColor
        return textView
    }()

    private let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("確認", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.pink3.withAlphaComponent(0.5)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.96, green: 0.89, blue: 0.78, alpha: 1) // 類似附圖的淺棕色背景
        setupUI()
    }

    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(textView)
        view.addSubview(confirmButton)

        // Auto Layout 設定
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // 設置 titleLabel 的位置
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // 設置 textField 的位置
            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            textView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textView.widthAnchor.constraint(equalToConstant: 280),
            textView.heightAnchor.constraint(equalToConstant: 150),

            // 設置 confirmButton 的位置
            confirmButton.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 20),
            confirmButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        // 設定初始的文字
        textView.text = copiedText

        // 按下確認按鈕
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
    }

    @objc private func confirmButtonTapped() {
        guard let updatedText = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines), !updatedText.isEmpty else {
            AlertKitManager.presentErrorAlert(in: self, title: "我沒有讀到文字哦")
            return
        }

        if updatedText.count > 45 {
            AlertKitManager.presentErrorAlert(in: self, title: "文太多的話，早安圖會不可愛")
            return
        }

        onConfirm?(updatedText)
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = .push
        transition.subtype = .fromRight

        view.window?.layer.add(transition, forKey: kCATransition)

        dismiss(animated: false, completion: nil)
    }
}
