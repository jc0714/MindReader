//
//  SettingVC.swift
//  MindReader
//
//  Created by J oyce on 2024/9/26.
//

import Foundation
import UIKit
import Firebase
import Lottie

class SettingVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UserInfoCellDelegate {

    let animationView = LottieAnimationView(name: "dayAndNight")
    var isNightMode = false

    private let titleLabel = createLabel(text: "設定", fontSize: 24, fontWeight: .bold, textColor: .pink3)
    private var tableView: UITableView!
    private var userName: String = ""

    private let firestoreService = FirestoreService()

    private var settingsItems: [[String]] = [
        ["名字"], // 第一组
        ["  封鎖名單", "  淺色/深色模式", "  回報問題", "  隱私權政策"], // 第二组
        ["  刪除帳號", "  登出"] // 第三组
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
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 70),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UserInfoCell.self, forCellReuseIdentifier: "UserInfoCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false

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
        if section == 0 {
            return settingsItems[section].count
        }
        return 1 // 第二和第三個 section 只返回一行
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserInfoCell", for: indexPath) as? UserInfoCell else {
                return UITableViewCell()
            }
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            cell.configure(with: userName, icon: UIImage(named: "photo4"))
            cell.delegate = self
            return cell
        } else {
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            cell.backgroundColor = .clear

            let stackView = createStackView()

            for (index, item) in settingsItems[indexPath.section].enumerated() {
                let button = createButton(withTitle: item, section: indexPath.section, row: index)

                // 檢查是否是 "淺色/深色模式"，是的話添加動畫
                if item == "  淺色/深色模式" {
                    button.isUserInteractionEnabled = false
                    let horizontalStack = createHorizontalStackView(with: button)
                    stackView.addArrangedSubview(horizontalStack)
                } else {
                    stackView.addArrangedSubview(button)
                }
            }

            cell.contentView.addSubview(stackView)
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 10),
                stackView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 15),
                stackView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -15),
                stackView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -10)
            ])
            return cell
        }
    }

    // MARK: - 輔助方法
    private func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.backgroundColor = .white
        stackView.layer.cornerRadius = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }

    private func createButton(withTitle title: String, section: Int, row: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.contentHorizontalAlignment = .left
        button.tag = section * 100 + row  // 將 section 和 row 組合存儲
        button.addTarget(self, action: #selector(settingItemTapped(_:)), for: .touchUpInside)
        return button
    }

    private func createHorizontalStackView(with button: UIButton) -> UIStackView {
        let horizontalStack = UIStackView()
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 10
        horizontalStack.alignment = .center
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false

        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        animationView.clipsToBounds = true
        animationView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        animationView.heightAnchor.constraint(equalToConstant: 60).isActive = true

        let transparentButton = UIButton(type: .system)
        transparentButton.backgroundColor = .clear  // 設置背景為透明
        transparentButton.addTarget(self, action: #selector(turnDayAndNight), for: .touchUpInside)
        transparentButton.translatesAutoresizingMaskIntoConstraints = false

        horizontalStack.addArrangedSubview(button)
        horizontalStack.addArrangedSubview(animationView)

        animationView.addSubview(transparentButton)
        NSLayoutConstraint.activate([
            transparentButton.centerXAnchor.constraint(equalTo: animationView.centerXAnchor),
            transparentButton.centerYAnchor.constraint(equalTo: animationView.centerYAnchor),
            transparentButton.widthAnchor.constraint(equalToConstant: 50),
            transparentButton.heightAnchor.constraint(equalToConstant: 25)
        ])
        return horizontalStack
    }

    @objc private func settingItemTapped(_ sender: UIButton) {
        let section = sender.tag / 100 // 取得 section
        let row = sender.tag % 100

        let selectedItem = settingsItems[section][row]

        switch selectedItem {
        case "  封鎖名單":
            let blockedListVC = BlockedListVC()
            if let sheet = blockedListVC.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
            }
            present(blockedListVC, animated: true, completion: nil)
        case "  回報問題":
            showReportIssueVC()
        case "  隱私權政策":
            showPrivacyPolicyVC()
        case "  刪除帳號":
            showDeleteAccountAlert()
        case "  登出":
            showLogoutAlert()
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "帳號資訊"
        case 1:
            return "其他"
        case 2:
            return "想離開"
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 150
        } else {
            return UITableView.automaticDimension // 自動計算高度
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

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    //MARK: 淺色/深色模式
    @objc private func turnDayAndNight() {
        if isNightMode {
            // 從夜間轉回日間 (播放後半段 0.5 -> 1.0)
            animationView.play(fromProgress: 0.5, toProgress: 1.0)
        } else {
            // 從日間轉到夜間 (播放前半段 0.0 -> 0.5)
            animationView.play(fromProgress: 0.0, toProgress: 0.5)
        }
        isNightMode.toggle()  // 切換模式狀態
    }

    // MARK: 回報問題
    private func showReportIssueVC() {
        let reportVC = ReportIssueViewController()
        reportVC.modalPresentationStyle = .formSheet
        self.present(reportVC, animated: true, completion: nil)
    }

    private func showPrivacyPolicyVC() {
        let privacyPolicyVC = PrivacyPolicyViewController()
        privacyPolicyVC.title = "隱私權政策"
        navigationController?.pushViewController(privacyPolicyVC, animated: true)
    }

    // MARK: 刪除帳號
    private func showDeleteAccountAlert() {
        let alert = UIAlertController(title: "刪除帳號", message: "這將無法復原您的資料，您確定要繼續嗎？", preferredStyle: .alert)

        let confirmAction = UIAlertAction(title: "確認", style: .destructive) { [weak self] _ in
            self?.firestoreService.deleteAccount()

            self?.showLoginVC()
        }

        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)

        alert.addAction(confirmAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    // MARK: 登出
    private func showLogoutAlert() {
        let alert = UIAlertController(title: "登出", message: "確定要登出嗎？期待你下次再登入。", preferredStyle: .alert)

        let confirmAction = UIAlertAction(title: "確認", style: .destructive) { _ in
            UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
            UserDefaults.standard.set(nil, forKey: "userID")

            self.showLoginVC()
        }

        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)

        alert.addAction(confirmAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    func showLoginVC() {
        let loginVC = LoginVC()
        loginVC.modalPresentationStyle = .fullScreen

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = loginVC
            window.makeKeyAndVisible()
        }
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
