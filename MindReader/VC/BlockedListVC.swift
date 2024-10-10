//
//  BlockedListVC.swift
//  MindReader
//
//  Created by J oyce on 2024/10/3.
//

import Foundation
import UIKit
import Firebase

class BlockedListVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var blockedList: [String: String] = [:]
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCloseButton()
        loadBlockedList()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
    }

    private func setupUI() {
        view.backgroundColor = .white
        title = "封鎖名單"

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(BlockedListCell.self, forCellReuseIdentifier: "BlockedListCell")

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60)
        ])
    }

    private func setupCloseButton() {
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("close", for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)

        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    private func loadBlockedList() {
        blockedList = UserDefaults.standard.dictionary(forKey: "BlockedList") as? [String: String] ?? [:]
        tableView.reloadData()
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blockedList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlockedListCell", for: indexPath) as? BlockedListCell
        let userName = Array(blockedList.values)[indexPath.row]

        cell!.configure(with: userName)

        return cell!
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userToUnblock = Array(blockedList.keys)[indexPath.row]

        // 確認解除封鎖的彈出框
        let alert = UIAlertController(title: "解除封鎖", message: "確定要解除對 \(userToUnblock) 的封鎖嗎？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "解除", style: .destructive, handler: { _ in
            self.unblockUser(at: indexPath)
        }))
        present(alert, animated: true, completion: nil)
    }

    private func unblockUser(at indexPath: IndexPath) {
        let userId = Array(blockedList.keys)[indexPath.row]

        blockedList.removeValue(forKey: userId)

        UserDefaults.standard.set(blockedList, forKey: "BlockedList")

        updateBlockedListInFirebase(userId: userId)

        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

    private func updateBlockedListInFirebase(userId: String) {
        guard let currentUserID = UserDefaults.standard.string(forKey: "userID") else { return }

        let userRef = Firestore.firestore().collection("Users").document(currentUserID)

        userRef.updateData([
            "blockedList": FieldValue.arrayRemove([userId])
        ]) { error in
            if let error = error {
            } else {
                print("封鎖名單已成功更新到 Firebase")
            }
        }
    }
}
