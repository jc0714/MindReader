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

    private let commentTextField = UITextField()
    private let sendButton = UIButton(type: .system)

    private let fireStoreService = FirestoreService()
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
        tableView.register(CommentCell.self, forCellReuseIdentifier: "CommentCell")
        view.backgroundColor = UIColor.albumBackground

        setupTableView()
        setupCloseButton()
        setupInputArea()

        listener = fireStoreService.setupFirestoreListener(for: postId) { [weak self] comments in
            self?.comments = comments
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }

    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
        listener?.remove() // 移除 Firestore 監聽器
    }

    // MARK: - UI Setup
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .albumBackground

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
        closeButton.setTitle("✕", for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
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
        guard let commentText = commentTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !commentText.isEmpty else { return }

        guard let userId = UserDefaults.standard.string(forKey: "userID"), let userName =                 UserDefaults.standard.string(forKey: "userLastName") else {
            print("User ID is nil")
            return
        }

        let documentID = UUID().uuidString
        let newComment: [String: Any] = [
            "author": userName,
            "authorId": userId,
            "content": commentText,
            "timestamp": Timestamp(date: Date())
        ]

        let postRef = Firestore.firestore().collection("posts").document(postId).collection("Comments").document(documentID)
        postRef.setData(newComment) { error in
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

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentCell

        let comment = comments[indexPath.row]

        cell?.configure(author: comment.author, content: comment.content, timestamp: comment.timestamp)
        cell?.selectionStyle = .none

        return cell!
    }
}
