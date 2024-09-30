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
    var heartCount: Int = 0

    let imageNames = ["photo4", "photo5", "photo6", "photo7"]

    var postId: String = ""

    var postStackView = UIStackView()

    private let tableView = UITableView()

    private let commentTextField = UITextField()
    private let sendButton = UIButton(type: .system)

    // Firestore 監聽器
    private let fireStoreService = FirestoreService()
    private var listener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .color

        setUpNavigation()

        setupInputArea()

        setupTableView()

        if let postId = post?.id {
            self.postId = postId
        }

        listener = fireStoreService.setupFirestoreListener(for: postId) { [weak self] comments in
            self?.comments = comments
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(handleCommentCountUpdate(_:)), name: NSNotification.Name("CommentCountUpdated"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener?.remove()
        navigationController?.setNavigationBarHidden(true, animated: true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("LikeCountUpdated"), object: nil)
    }

    func setUpNavigation() {

         // 設置導航欄背景顏色
        navigationController?.setNavigationBarHidden(false, animated: true)

        navigationController?.navigationBar.isTranslucent = false

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground() // 設置為不透明背景
        appearance.backgroundColor = .color

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
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
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
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

        guard let userId = UserDefaults.standard.string(forKey: "userID"), let userName =                 UserDefaults.standard.string(forKey: "userLastName") else {
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
                cell.selectionStyle = .none
                cell.configure(with: post, imageUrl: post.image)

                if BasePostVC.likedPosts.contains(post.id) {
                    cell.heartButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                } else {
                    cell.heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
                }

                cell.heartCount.text = String(heartCount)

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
            cell.selectionStyle = .none
            cell.configure(author: comment.author, content: comment.content, timestamp: comment.timestamp)

            return cell
        }
    }

    // 留言刪除 誰可以
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard indexPath.row > 0 else { return false }

        let comment = comments[indexPath.row - 1]

        if let userId = UserDefaults.standard.string(forKey: "userId") {
            return comment.authorId == userId
        }

        return false
    }

    // 留言刪除 UI Firebase 都要記得
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let commentId = comments[indexPath.row - 1].id

            let postRef = Firestore.firestore().collection("posts").document(postId).collection("Comments").document(commentId)

            postRef.delete()
        }
    }

    func updateHeartBtn(at indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? PostCell

        // 批次寫入操作
        let batch = Firestore.firestore().batch()
        let postRef = Firestore.firestore().collection("posts").document(postId)

        guard let userId = UserDefaults.standard.string(forKey: "userID") else {
            print("User ID is nil")
            return
        }

        let userRef = Firestore.firestore().collection("Users").document(userId)

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

            } catch {
                print("Error updating likes: \(error.localizedDescription)")
            }
        }

    }
    
    @objc private func handleCommentCountUpdate(_ notification: Notification) {
        // 獲取通知中的 postId 和新的留言數量
        guard let userInfo = notification.userInfo,
              let postId = userInfo["postId"] as? String,
              let newCommentCount = userInfo["count"] as? Int else {
            return
        }

        // 確保更新對應的 post
        if post?.id == postId {
            post?.comment = newCommentCount // 更新 post 的 comment
            DispatchQueue.main.async {
                // 獲取對應的 cell 並更新顯示
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PostCell {
                    cell.commentCount.text = "\(newCommentCount)" // 更新留言數量
                }
            }
        }
    }
}
