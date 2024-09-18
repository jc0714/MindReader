//
//  CommentsVC.swift
//  MindReader
//
//  Created by J oyce on 2024/9/18.
//

import Foundation
import UIKit
import FirebaseFirestore

class CommentsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let tableView = UITableView()
    private var comments: [String] = [] // 儲存留言的內容
    private var postId: String // 需要傳入 postId 來監聽特定的貼文
    private var listener: ListenerRegistration?

    // MARK: - Initializer
    init(postId: String) {
        self.postId = postId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white.withAlphaComponent(0.9)

        setupTableView()
        setupCloseButton()
        setupFirestoreListener()  // 開始監聽 Firestore
    }

    // MARK: - Firestore Listener
    private func setupFirestoreListener() {
        let postRef = Firestore.firestore().collection("posts").document(postId)

        listener = postRef.addSnapshotListener { [weak self] documentSnapshot, error in
            guard let self = self, let document = documentSnapshot, error == nil else {
                print("Error fetching comments: \(String(describing: error))")
                return
            }

            // 獲取最新的 comments 陣列
            if let data = document.data(), let commentsData = data["Comments"] as? [[String: Any]] {
                self.comments = commentsData.compactMap { comment in
                    return comment["content"] as? String // 提取每則留言的內容
                }

                // 更新 UI
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }

    // MARK: - UI Setup
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupCloseButton() {
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("關閉", for: .normal)
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
        listener?.remove() // 移除 Firestore 監聽器
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = comments[indexPath.row]
        return cell
    }
}