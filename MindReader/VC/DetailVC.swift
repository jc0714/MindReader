//
//  DetailVC.swift
//  MindReader
//
//  Created by J oyce on 2024/9/25.
//

import Foundation
import UIKit
import FirebaseFirestore
import IQKeyboardManagerSwift

class DetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource, KeyboardHandler {

    var post: Post? // 用來接收傳遞的 post 物件
    var comments: [Comment] = [] // 留言數組
    var heartCount: Int = 0

    private let inputContainer = UIView()
    var inputAreaBottomConstraint: NSLayoutConstraint?

    private let imageNames = ["avatar1", "avatar2", "avatar3", "avatar4", "avatar5", "avatar6", "avatar7", "avatar8"]

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
        view.backgroundColor = .milkYellow

        setUpNavigation()

        setupInputArea()

        setupTableView()

        setupKeyboardObservers()

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
        self.tabBarController?.tabBar.isHidden = true
        IQKeyboardManager.shared.enable = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener?.remove()
        self.tabBarController?.tabBar.isHidden = false
        IQKeyboardManager.shared.enable = true
        navigationController?.setNavigationBarHidden(true, animated: true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("LikeCountUpdated"), object: nil)
    }

    func keyboardWillShow(keyboardHeight: CGFloat) {
        DispatchQueue.main.async {
            self.inputAreaBottomConstraint?.constant = -keyboardHeight + 20
            self.view.layoutIfNeeded()
        }
    }

    func keyboardWillHide() {
        DispatchQueue.main.async {
            self.inputAreaBottomConstraint?.constant = -10
            self.view.layoutIfNeeded()
        }
    }

    deinit {
        removeKeyboardObservers()
    }

    func setUpNavigation() {

        navigationController?.navigationBar.isTranslucent = false

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground() // 設置為不透明背景
        appearance.backgroundColor = .milkYellow

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
        tableView.separatorStyle = .none

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainer.topAnchor, constant: -10)
        ])
    }

    private func setupInputArea() {
        commentTextField.placeholder = "輸入留言..."
        commentTextField.borderStyle = .roundedRect
        sendButton.setTitle("送出", for: .normal)

        inputContainer.backgroundColor = .milkYellow

        inputContainer.addSubview(commentTextField)
        inputContainer.addSubview(sendButton)

        view.addSubview(inputContainer)

        commentTextField.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        inputContainer.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            commentTextField.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 10),
            commentTextField.topAnchor.constraint(equalTo: inputContainer.topAnchor, constant: 5),
            commentTextField.bottomAnchor.constraint(equalTo: inputContainer.bottomAnchor, constant: -5),
            commentTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
            commentTextField.heightAnchor.constraint(equalToConstant: 40),

            sendButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -10),
            sendButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 60),
            sendButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        inputAreaBottomConstraint = inputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        NSLayoutConstraint.activate([
            inputContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputAreaBottomConstraint!,
            inputContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])

        sendButton.addTarget(self, action: #selector(sendComment), for: .touchUpInside)
    }

    @objc private func sendComment() {
        guard let commentText = commentTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !commentText.isEmpty else { return }

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

                cell.reportButtonTappedClosure = { [weak self] action in
                    self?.handleOptionSelection(action: action, at: indexPath)
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

            cell.reportButtonTappedClosure = { [weak self] action in
                self?.handleOptionSelection(action: action, at: indexPath)
            }

            return cell
        }
    }

    func handleOptionSelection(action: String, at indexPath: IndexPath) {
        let currentUserId = UserDefaults.standard.string(forKey: "userID")
        if indexPath.row == 0 {
            // 第一個 cell 是貼文
            guard let post = post else { return }
            let authorId = post.author.id
            let authorName = post.author.name
            let postId = post.id

            if authorId == currentUserId {
                AlertKitManager.presentErrorAlert(in: self, title: "不要檢舉/封鎖自己啦")
                return
            }

            switch action {
            case "檢舉":
                showReportReasonSelection(forID: postId, isPost: true)
            case "封鎖":
                showBlockConfirmation(forUserId: authorId, authorName: authorName)
            default:
                break
            }
        } else {
            // 其他 cell 是留言
            let comment = comments[indexPath.row - 1]
            let authorId = comment.authorId
            let authorName = comment.author
            let commentId = comment.id

            if authorId == currentUserId {
                AlertKitManager.presentErrorAlert(in: self, title: "不要檢舉/封鎖自己啦")
                return
            }

            switch action {
            case "檢舉":
                // 處理留言的檢舉邏輯
                showReportReasonSelection(forID: commentId, isPost: false)
            case "封鎖":
                // 彈出確認框
                showBlockConfirmation(forUserId: authorId, authorName: authorName)
            default:
                break
            }
        }
    }

    // 檢舉（貼文或留言）
    private func showReportReasonSelection(forID id: String, isPost: Bool) {
        let alertController = UIAlertController(title: "選擇檢舉原因", message: nil, preferredStyle: .actionSheet)

        let reasons = ["不感興趣", "謾罵", "人身攻擊", "其他"]

        for reason in reasons {
            let action = UIAlertAction(title: reason, style: .default) { _ in
                // 根據選擇的原因處理檢舉邏輯
                if isPost {
                    ReportPostManager.shared.addToReportedPostList(postID: id)
                    ReportPostManager.shared.updateReportedPostListInFirebase(postID: id, reason: reason)
                    print("檢舉貼文原因：\(reason)")
                } else {
                    ReportCommentManager.shared.addToReportedCommentList(commentID: id)
                    ReportCommentManager.shared.updateReportedCommentListInFirebase(commentID: id, reason: reason)
                    print("檢舉留言原因：\(reason)")
                }
            }
            alertController.addAction(action)
        }

        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        // 呈現視窗
        self.present(alertController, animated: true, completion: nil)
    }

    // 封鎖
    private func showBlockConfirmation(forUserId userId: String, authorName: String) {
        let alertController = UIAlertController(title: "封鎖用戶", message: "您確定要封鎖這位用戶嗎？", preferredStyle: .alert)

        let confirmAction = UIAlertAction(title: "確定", style: .destructive) { _ in
            BlockManager.shared.blockUser(authorID: userId, authorName: authorName)
        }

        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)

        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }

    // 留言刪除 誰可以
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard indexPath.row > 0 else { return false }

        let comment = comments[indexPath.row - 1]

        if let userId = UserDefaults.standard.string(forKey: "userID") {
            return comment.authorId == userId
        }

        return false
    }

    // 留言刪除 UI Firebase 都要記得
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "刪除") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }

            let alertController = UIAlertController(title: "確定刪除？", message: "此動作無法復原", preferredStyle: .alert)

            let confirmAction = UIAlertAction(title: "確定", style: .destructive) { _ in
                let commentId = self.comments[indexPath.row - 1].id
                let postRef = Firestore.firestore().collection("posts").document(self.postId).collection("Comments").document(commentId)

                postRef.delete { error in
                    if let error = error {
                        print("Error deleting document: \(error)")
                    } else {
                        print("Document successfully deleted")
                    }
                }
                completionHandler(true)
            }
            alertController.addAction(confirmAction)

            let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in
                completionHandler(false)
            }
            alertController.addAction(cancelAction)

            self.present(alertController, animated: true, completion: nil)
        }

        deleteAction.backgroundColor = UIColor.delete

        return UISwipeActionsConfiguration(actions: [deleteAction])
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
