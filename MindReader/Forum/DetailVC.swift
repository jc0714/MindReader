//
//  DetailVC.swift
//  MindReader
//
//  Created by J oyce on 2024/9/25.
//

import Foundation
import UIKit
import FirebaseFirestore

class DetailVC: HideTabBarVC, UITableViewDelegate, UITableViewDataSource {

    var post: Post? // 用來接收傳遞的 post 物件
    var comments: [Comment] = [] // 留言數組

    let imageNames = ["photo4", "photo5", "photo6", "photo7"]

    var postId: String = ""

    var postStackView = UIStackView()

    private let tableView = UITableView()

    private let commentTextField = UITextField()
    private let sendButton = UIButton(type: .system)

    private let userRef = Firestore.firestore().collection("Users").document("9Y2GjnVg8TEoze0GUJSU")
    private let userId = "9Y2GjnVg8TEoze0GUJSU"

    // Firestore 監聽器
    private var listener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupInputArea()

        setupTableView()

        if let postId = post?.id {
            self.postId = postId
            fetchComments(for: postId)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener?.remove()
    }

    // 配置 TableView
    private func setupTableView() {
        tableView.register(PostCell.self, forCellReuseIdentifier: "PostCell")
        tableView.register(CommentCell.self, forCellReuseIdentifier: "CommentCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
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

    // 從 Firestore 獲取留言
    private func fetchComments(for postId: String) {
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

    // UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + comments.count // 第一個 cell 顯示 post，後面的 cell 顯示留言
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            // 顯示 post 的 cell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell else {
                return UITableViewCell()
            }
            if let post = post {
                cell.avatarImageView.image = UIImage(named: imageNames[post.avatar])
                cell.articleTitle.text = post.title
                cell.authorName.text = post.author.name
                cell.createdTimeLabel.text = post.createdTime
                cell.categoryLabel.text = post.category
                cell.contentLabel.text = post.content
                cell.heartCount.text = String(post.like)
                cell.commentCount.text = String(post.comment)
                cell.configure(with: post.image)

                if BasePostVC.likedPosts.contains(post.id) {
                    cell.heartButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                } else {
                    cell.heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
                }

                cell.heartButtonTappedClosure = { [weak self] in
                    self?.updateHeartBtn(at: indexPath)
                }
            }
            return cell
        } else {
            // 顯示留言的 cell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentCell else {
                return UITableViewCell()
            }

            let comment = comments[indexPath.row - 1] // 留言從第 1 行開始
            cell.configure(author: comment.author, content: comment.content, timestamp: comment.timestamp)

            return cell
        }
    }

    func updateHeartBtn(at indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? PostCell

        // 批次寫入操作
        let batch = Firestore.firestore().batch()
        let postRef = Firestore.firestore().collection("posts").document(postId)

        if BasePostVC.likedPosts.contains(postId) {
            // 如果用戶已經按了讚，則移除讚
            batch.updateData(["like": FieldValue.arrayRemove([userId])], forDocument: postRef)
            batch.updateData(["likePosts": FieldValue.arrayRemove([postId])], forDocument: userRef)

            // 更新本地數據，移除已按讚的文章
            BasePostVC.likedPosts.remove(postId)
            post?.like -= 1
            cell?.heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
        } else {
            // 如果用戶還未按讚，則添加讚
            batch.updateData(["like": FieldValue.arrayUnion([userId])], forDocument: postRef)
            batch.updateData(["likePosts": FieldValue.arrayUnion([postId])], forDocument: userRef)

            // 更新本地數據，添加已按讚的文章
            BasePostVC.likedPosts.insert(postId)
            post?.like += 1
            cell?.heartButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }

        // 更新愛心數量顯示
        cell?.heartCount.text = String(post!.like)

        // 提交批次寫入操作
        Task {
            do {
                try await batch.commit()
                NotificationCenter.default.post(name: NSNotification.Name("RefreshDataNotification"), object: nil)

            } catch {
                print("Error updating likes: \(error.localizedDescription)")
            }
        }

    }
}