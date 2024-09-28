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

    // UI 元件
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "輸入新的姓氏"
        textField.borderStyle = .roundedRect
        return textField
    }()

    let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("送出", for: .normal)
        button.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        let userLastName = UserDefaults.standard.string(forKey: "userLastName")
        nameTextField.text = userLastName
        
        setupUI()
    }

    // 設置 UI
    func setupUI() {
        view.backgroundColor = .white

        // 添加 TextField 和 Button
        view.addSubview(nameTextField)
        view.addSubview(submitButton)

        // 設置佈局 (這裡簡單地使用 frame)
        nameTextField.frame = CGRect(x: 20, y: 100, width: view.frame.width - 40, height: 40)
        submitButton.frame = CGRect(x: 20, y: 160, width: view.frame.width - 40, height: 40)
    }

    // 送出按鈕的動作
    @objc func submitButtonTapped() {
        guard let newName = nameTextField.text, !newName.isEmpty else {
            print("請輸入新的姓氏")
            return
        }

        // 呼叫更新 Firebase 的方法
        updateNameInFirebase(newName: newName)
    }

    // 更新 Firebase 中的 name 欄位
    func updateNameInFirebase(newName: String) {
        // 假設這裡已經有一個已登入的用戶 ID
        guard let userId = UserDefaults.standard.string(forKey: "userID") else {
            print("User ID is nil")
            return
        }

        // 更新 Firebase 中的 name 欄位
        let usersCollection = Firestore.firestore().collection("Users")
        usersCollection.document(userId).updateData(["name": newName]) { error in
            if let error = error {
                print("更新失敗：\(error.localizedDescription)")
            } else {
                print("姓名已成功更新")

                // 將新的姓氏存入 UserDefaults
                UserDefaults.standard.set(newName, forKey: "userLastName")
                print("新的姓氏已存入 UserDefaults")
            }
        }
    }
}
