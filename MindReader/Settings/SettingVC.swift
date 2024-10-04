//
//  SettingVC.swift
//  MindReader
//
//  Created by J oyce on 2024/9/26.
//

import Foundation
import UIKit
import Firebase

class SettingVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UserInfoCellDelegate {

    private let titleLabel = createLabel(text: "設定", fontSize: 24, fontWeight: .bold, textColor: .pink3)
    private var tableView: UITableView!
    private var userName: String = ""

    private let firestoreService = FirestoreService()

    private var settingsItems: [[(title: String, icon: UIImage?)]] = [
        [("名字", UIImage(systemName: "pencil"))], // 第一组
        [
            ("封鎖名單", UIImage(systemName: "paintpalette.fill")),
            ("回報問題", UIImage(systemName: "exclamationmark.bubble.fill"))
        ], // 第二组
        [
            ("刪除帳號", UIImage(systemName: "trash.fill")),
            ("登出", UIImage(systemName: "heart.fill"))
        ] // 第三组
    ]

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

        tableView = UITableView(frame: .zero, style: .grouped) // 使用 grouped 样式
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UserInfoCell.self, forCellReuseIdentifier: "UserInfoCell")
        tableView.register(SettingItemCell.self, forCellReuseIdentifier: "SettingItemCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadUserName() {
        userName = UserDefaults.standard.string(forKey: "userLastName") ?? "UUUU"
    }

    // MARK: - UITableViewDataSource 方法
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingsItems.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsItems[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = settingsItems[indexPath.section][indexPath.row]

        if indexPath.section == 0 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserInfoCell", for: indexPath) as? UserInfoCell
            cell?.configure(with: userName, icon: UIImage(named: "photo1"))
            cell?.delegate = self
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingItemCell", for: indexPath) as? SettingItemCell
            cell?.configure(with: item.title, icon: item.icon)
            return cell!
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "用戶信息"
        case 1:
            return "設置"
        case 2:
            return "帳號操作"
        default:
            return nil
        }
    }

    // MARK: - UITableViewDelegate 方法
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedItem = settingsItems[indexPath.section][indexPath.row].title

        switch selectedItem {
        case "封鎖名單":
            let blockedListVC = BlockedListVC()
            if let sheet = blockedListVC.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
            }
            present(blockedListVC, animated: true, completion: nil)
        case "回報問題":
            
            print("回報問題")
        case "刪除帳號":
            showDeleteAccountAlert()

            print("刪除帳號")
        case "登出":
            UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
            print("登出")
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 150
        } else {
            return 60
        }
    }

    private static func createLabel(text: String, fontSize: CGFloat, fontWeight: UIFont.Weight, textColor: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        label.textColor = textColor
        label.textAlignment = .center
        return label
    }

    private func showDeleteAccountAlert() {
        let alert = UIAlertController(title: "刪除帳號", message: "這將無法復原您的數據，您確定要繼續嗎？", preferredStyle: .alert)

        let confirmAction = UIAlertAction(title: "確認", style: .destructive) { [weak self] _ in
            self?.firestoreService.deleteAccount()
            print("刪除帳號")
        }

        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)

        alert.addAction(confirmAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    func didTapSubmitButton(newName: String, in cell: UserInfoCell) {
        guard let userId = UserDefaults.standard.string(forKey: "userID") else { return }

        let usersCollection = Firestore.firestore().collection("Users")
        usersCollection.document(userId).updateData(["userFullName": newName]) { error in
            if error == nil {
                UserDefaults.standard.set(newName, forKey: "userLastName")
                self.userName = newName
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
}

//class SettingVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UserInfoCellDelegate {
//
//    private let titleLabel = createLabel(text: "設定", fontSize: 24, fontWeight: .bold, textColor: .pink3)
//    private var tableView: UITableView!
//    private var userName: String = ""
//
//    private var settingsItems: [(title: String, icon: UIImage?)] = [
//        ("名字", UIImage(systemName: "pencil")),
//        ("封鎖名單", UIImage(systemName: "paintpalette.fill")),
//        ("回報問題", UIImage(systemName: "exclamationmark.bubble.fill")),
//        ("刪除帳號", UIImage(systemName: "trash.fill")),
//        ("登出", UIImage(systemName: "heart.fill"))
//    ]
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        loadUserName()
//    }
//
//    private func setupUI() {
//        view.backgroundColor = UIColor(red: 255/255, green: 245/255, blue: 238/255, alpha: 1)
//
//        view.addSubview(titleLabel)
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
//        ])
//
//        tableView = UITableView(frame: .zero, style: .plain)
//        tableView.backgroundColor = .clear
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.register(UserInfoCell.self, forCellReuseIdentifier: "UserInfoCell")
//        tableView.register(SettingItemCell.self, forCellReuseIdentifier: "SettingItemCell")
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 60
//
//        view.addSubview(tableView)
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//    }
//
//    private func loadUserName() {
//        userName = UserDefaults.standard.string(forKey: "userLastName") ?? "UUUU"
//    }
//
//    // MARK: - UITableViewDataSource 方法
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return settingsItems.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.row == 0 {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "UserInfoCell", for: indexPath) as? UserInfoCell
//            cell?.configure(with: userName, icon: UIImage(named: "photo1"))
//            cell?.delegate = self
//            return cell!
//        } else {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingItemCell", for: indexPath) as? SettingItemCell
//            let item = settingsItems[indexPath.row]
//            cell!.configure(with: item.title, icon: item.icon)
//            return cell!
//        }
//    }
//
//    // MARK: - UITableViewDelegate 方法
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//
//        if indexPath.row == 1 { // "封鎖名單"
//            let blockedListVC = BlockedListVC()
//            if let sheet = blockedListVC.sheetPresentationController {
//                sheet.detents = [.medium(), .large()]
//                sheet.prefersGrabberVisible = true
//            }
//            present(blockedListVC, animated: true, completion: nil)
//        } else {
//            switch indexPath.row {
//            case 2:
//                print("回報問題")
//            case 3:
//                UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
//
//                print("登出")
//            default:
//                break
//            }
//        }
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.row == 0 {
//            return 150
//        } else {
//            return 60
//        }
//    }
//
//    private static func createLabel(text: String, fontSize: CGFloat, fontWeight: UIFont.Weight, textColor: UIColor) -> UILabel {
//        let label = UILabel()
//        label.text = text
//        label.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
//        label.textColor = textColor
//        label.textAlignment = .center
//        return label
//    }
//
//    func didTapSubmitButton(newName: String, in cell: UserInfoCell) {
//        guard let userId = UserDefaults.standard.string(forKey: "userID") else { return }
//
//        let usersCollection = Firestore.firestore().collection("Users")
//        usersCollection.document(userId).updateData(["userFullName": newName]) { error in
//            if error == nil {
//                UserDefaults.standard.set(newName, forKey: "userLastName")
//                self.userName = newName
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//            }
//        }
//    }
//}
