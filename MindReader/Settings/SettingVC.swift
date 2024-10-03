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

    // 数据模型
    private var settingsItems: [(title: String, icon: UIImage?)] = [
        ("名字", UIImage(systemName: "pencil")),
        ("封鎖名單", UIImage(systemName: "paintpalette.fill")),
        ("回報問題", UIImage(systemName: "exclamationmark.bubble.fill")),
        ("登出", UIImage(systemName: "heart.fill"))
    ]

    private var isBlockedListExpanded = false // 用于跟踪封鎖名單单元格是否展开

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

        tableView = UITableView(frame: .zero, style: .plain)
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserInfoCell", for: indexPath) as? UserInfoCell
            cell?.configure(with: userName, icon: UIImage(named: "photo1"))
            cell?.delegate = self
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingItemCell", for: indexPath) as? SettingItemCell
            let item = settingsItems[indexPath.row]
            cell!.configure(with: item.title, icon: item.icon)
            return cell!
        }
    }

    // MARK: - UITableViewDelegate 方法
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.row == 1 { // "封鎖名單"
            let blockedListVC = BlockedListVC()
            if let sheet = blockedListVC.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
            }
            present(blockedListVC, animated: true, completion: nil)
        } else {
            switch indexPath.row {
            case 2:
                print("回報問題")
            case 3:
                print("登出")
            default:
                break
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
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

//class SettingVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UserInfoCellDelegate {
//
//    private let titleLabel = createLabel(text: "設定", fontSize: 24, fontWeight: .bold, textColor: .pink3)
//
//    private var collectionView: UICollectionView!
//    private var userName: String = ""
//
//    // 数据模型
//    private var settingsItems: [(title: String, icon: UIImage?)] = [
//        ("名字", UIImage(systemName: "pencil")),
//        ("封鎖名單", UIImage(systemName: "paintpalette.fill")),
//        ("回報問題", UIImage(systemName: "exclamationmark.bubble.fill")),
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
//        // 添加 titleLabel
//        view.addSubview(titleLabel)
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
//        ])
//
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .vertical
//        layout.minimumLineSpacing = 16
//        layout.sectionInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
//
//        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.backgroundColor = .clear
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        collectionView.register(UserInfoCell.self, forCellWithReuseIdentifier: "UserInfoCell")
//        collectionView.register(SettingItemCell.self, forCellWithReuseIdentifier: "SettingItemCell")
//
//        view.addSubview(collectionView)
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
//            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//    }
//
//    private func loadUserName() {
//        userName = UserDefaults.standard.string(forKey: "userLastName") ?? "UUUU"
//    }
//
//    // MARK: - UICollectionView DataSource 方法
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return settingsItems.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        if indexPath.row == 0 {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserInfoCell", for: indexPath) as? UserInfoCell
//            cell?.configure(with: userName, icon: UIImage(named: "photo1"))
//            cell?.delegate = self
//            return cell!
//        } else {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SettingItemCell", for: indexPath) as? SettingItemCell
//            let item = settingsItems[indexPath.item]
//            cell!.configure(with: item.title, icon: item.icon)
//            return cell!
//        }
//    }
//
//    // MARK: - UICollectionViewDelegateFlowLayout 方法
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if indexPath.row == 0 {
//            // 第一行 UserInfoCell 的高度
//            return CGSize(width: collectionView.frame.width - 32, height: 150)
//        } else {
//            return CGSize(width: collectionView.frame.width - 32, height: 60)
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
//                    self.collectionView.reloadData()
//                }
//            }
//        }
//    }
//}
