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
    private var comments: [Comment] = []
    private var postId: String
    private var listener: ListenerRegistration?

    private let commentTextField = UITextField()
    private let sendButton = UIButton(type: .system)

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
        tableView.register(CommentCell.self, forCellReuseIdentifier: "CommentCell")

        view.backgroundColor = UIColor.white.withAlphaComponent(0.9)

        setupTableView()
        setupCloseButton()
        setupInputArea()
        setupFirestoreListener()
    }

    // MARK: - Firestore Listener
    private func setupFirestoreListener() {
        let postRef = Firestore.firestore().collection("posts").document(postId)

        listener = postRef.addSnapshotListener { [weak self] documentSnapshot, error in
            guard let self = self, let document = documentSnapshot, error == nil else {
                print("Error fetching comments: \(String(describing: error))")
                return
            }

            if let data = document.data(), let commentsData = data["Comments"] as? [[String: Any]] {
                self.comments = commentsData.compactMap { comment in
                    guard let author = comment["author"] as? String,
                          let content = comment["content"] as? String,
                          let authorId = comment["authorId"] as? String,
                          let timestamp = comment["timestamp"] as? Timestamp else {
                        return nil
                    }

                    return Comment(author: author, authorId: authorId, content: content, timestamp: timestamp.dateValue())
                }

                // 更新留言數量
                let commentCount = commentsData.count
                NotificationCenter.default.post(name: NSNotification.Name("CommentCountUpdated"), object: nil, userInfo: ["postId": self.postId, "count": commentCount])

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
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60) // 留出空间给输入区域
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

    private func setupInputArea() {
        commentTextField.placeholder = "輸入留言..."
        commentTextField.borderStyle = .roundedRect
        sendButton.setTitle("送出", for: .normal)

        view.addSubview(commentTextField)
        view.addSubview(sendButton)

        commentTextField.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            commentTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            commentTextField.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            commentTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
            commentTextField.heightAnchor.constraint(equalToConstant: 40),

            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            sendButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            sendButton.widthAnchor.constraint(equalToConstant: 60),
            sendButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        sendButton.addTarget(self, action: #selector(sendComment), for: .touchUpInside)
    }

    @objc private func sendComment() {
        guard let commentText = commentTextField.text, !commentText.isEmpty else { return }

        let userId = "9Y2GjnVg8TEoze0GUJSU"

        let newComment: [String: Any] = [
            "author": "@0714JC",
            "authorId": userId,
            "content": commentText,
            "timestamp": Timestamp(date: Date())
        ]

        let postRef = Firestore.firestore().collection("posts").document(postId)
        postRef.updateData([
            "Comments": FieldValue.arrayUnion([newComment])
        ]) { error in
            if let error = error {
                print("Error adding comment: \(error)")
            } else {
                print("Comment successfully added!")
                DispatchQueue.main.async {
                    self.commentTextField.text = "" 
                }
            }
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentCell

        let comment = comments[indexPath.row]

        cell?.configure(author: comment.author, content: comment.content, timestamp: comment.timestamp)

        return cell!
    }
}
