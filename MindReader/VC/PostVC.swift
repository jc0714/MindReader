//
//  PostVC.swift
//  MindReader
//
//  Created by J oyce on 2024/9/21.
//

import Foundation
import UIKit
import FirebaseFirestore

class BasePostVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let tableView = UITableView()
    var posts: [Post] = []

    static var likedPosts: Set<String> = []

    private let tagFilterView = TagFilterView()
    var selectedTag: String = "All"

    var VCid: String = ""

    var currentPosts: [Post] {
        if selectedTag == "All" {
            return posts
        } else {
            return posts.filter { $0.category.contains(selectedTag) }
        }
    }

    private let imageNames = ["avatar1", "avatar2", "avatar3", "avatar4", "avatar5", "avatar6", "avatar7"]

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        loadLikedPosts()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300

        tableView.separatorStyle = .none

        if let savedTag = UserDefaults.standard.string(forKey: "\(VCid)_selectedTag") {
            selectedTag = savedTag
        }

        tagFilterView.tagSelectedClosure = { [weak self] selectedTag in
            self?.selectedTag = selectedTag
            UserDefaults.standard.set(selectedTag, forKey: "\(self?.VCid ?? "")_selectedTag")
            self?.tableView.reloadData()
        }

        NotificationCenter.default.addObserver(self, selector: #selector(handleCommentCountUpdate(_:)), name: NSNotification.Name("CommentCountUpdated"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: false)

        if let savedTag = UserDefaults.standard.string(forKey: "\(self.VCid)_selectedTag") {
            selectedTag = savedTag
            tableView.reloadData()
        }
    }

    private func setupUI() {
        view.addSubview(tagFilterView) 
        view.addSubview(tableView)

        tagFilterView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tagFilterView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tagFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tagFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tagFilterView.heightAnchor.constraint(equalToConstant: 50),

            tableView.topAnchor.constraint(equalTo: tagFilterView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        setupTableView()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(PostCell.self, forCellReuseIdentifier: "PostCell")
        tableView.delegate = self
        tableView.dataSource = self
    }

    // 初始化的時候把按過讚的愛心填滿
    private func loadLikedPosts() {
        guard let userId = UserDefaults.standard.string(forKey: "userID") else {
            print("User ID is nil")
            return
        }

        Firestore.firestore().collection("Users").document(userId).getDocument { [weak self] (document, error) in
            guard let self = self, let document = document, document.exists, let data = document.data() else {
                print("Error fetching liked posts: \(String(describing: error))")
                return
            }
            if let likePosts = data["likePosts"] as? [String] {
                BasePostVC.likedPosts = Set(likePosts)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // 配置 cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentPosts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard indexPath.row < currentPosts.count else {
            return UITableViewCell()
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell else {
            fatalError("Unable to dequeue PostCell")
        }

        cell.selectionStyle = .none

        let post = currentPosts[indexPath.row]
        cell.configure(with: post, imageUrl: post.image)

        if BasePostVC.likedPosts.contains(post.id) {
            cell.heartButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            cell.heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }

        cell.heartButtonTappedClosure = { [weak self] in
            self?.updateHeartBtn(at: indexPath)
        }

        cell.commentButtonTappedClosure = { [weak self] in
            self?.showCommentsForPost(at: indexPath)
        }

        cell.reportButtonTappedClosure = { [weak self] action in
            self?.handleOptionSelection(action: action, forPostAt: indexPath)
    }

        cell.setNeedsLayout()
        cell.layoutIfNeeded()

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    // 當點擊 post 時跳轉到這個貼文頁面
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < currentPosts.count else {
            return
        }

        let selectedPost = currentPosts[indexPath.row]
        let detailVC = DetailVC()
        detailVC.post = selectedPost // 將所選的 post 資料傳遞到 DetailVC
        detailVC.heartCount = currentPosts[indexPath.row].like
        navigationController?.pushViewController(detailVC, animated: true)
    }

    // 更新愛心實心空心狀態
    func updateHeartBtn(at indexPath: IndexPath) {
        guard let userId = UserDefaults.standard.string(forKey: "userID") else {
            print("User ID is nil")
            return
        }

        let userRef = Firestore.firestore().collection("Users").document(userId)
        let postId = currentPosts[indexPath.row].id
        let postRef = Firestore.firestore().collection("posts").document(postId)
        let cell = tableView.cellForRow(at: indexPath) as? PostCell

        // 批次寫入操作
        let batch = Firestore.firestore().batch()
        var isLiked = false

        if BasePostVC.likedPosts.contains(postId) {
            // 移除愛心
            batch.updateData(["like": FieldValue.arrayRemove([userId])], forDocument: postRef)
            batch.updateData(["likePosts": FieldValue.arrayRemove([postId])], forDocument: userRef)
            isLiked = false
        } else {
            // 添加愛心
            batch.updateData(["like": FieldValue.arrayUnion([userId])], forDocument: postRef)
            batch.updateData(["likePosts": FieldValue.arrayUnion([postId])], forDocument: userRef)
            isLiked = true
        }

        // 提交批次寫入操作
        Task {
            do {
                try await batch.commit()

                if let originalIndex = posts.firstIndex(where: { $0.id == postId }) {
                    posts[originalIndex].like += isLiked ? 1 : -1
                }

                // 更新本地數據和 UI
                if isLiked {
                    BasePostVC.likedPosts.insert(postId)
                    cell?.heartButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                } else {
                    BasePostVC.likedPosts.remove(postId)
                    cell?.heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
                }
                cell?.heartCount.text = String(currentPosts[indexPath.row].like)

            } catch {
                print("Error updating likes: \(error.localizedDescription)")
            }
        }
    }

    // 連結到留言 VC
    func showCommentsForPost(at indexPath: IndexPath) {
        let commentsVC = CommentsVC(postId: currentPosts[indexPath.row].id)
        if let sheet = commentsVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(commentsVC, animated: true, completion: nil)
    }

    func handleOptionSelection(action: String, forPostAt indexPath: IndexPath) {
        let post = currentPosts[indexPath.row]
        let authorId = post.author.id
        let postId = post.id

        switch action {
        case "檢舉":
            // 處理檢舉的邏輯
            showReportReasonSelection(forPostId: postId)
        case "封鎖":
            // 彈出確認框
            showBlockConfirmation(forUserId: authorId)

        default:
            break
        }
    }

    // 檢舉
    private func showReportReasonSelection(forPostId postId: String) {
        let alertController = UIAlertController(title: "選擇檢舉原因", message: nil, preferredStyle: .actionSheet)

        let reasons = ["不感興趣", "謾罵", "人身攻擊", "其他"]

        for reason in reasons {
            let action = UIAlertAction(title: reason, style: .default) { _ in
                // 根據選擇的原因處理檢舉邏輯
                self.addToReportedPostList(postID: postId)
                self.updateReportedPostListInFirebase(postID: postId, reason: reason)
                print("檢舉原因：\(reason)")
            }
            alertController.addAction(action)
        }

        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        // 呈現視窗
        self.present(alertController, animated: true, completion: nil)
    }

    private func addToReportedPostList(postID: String) {
        var reportedList = UserDefaults.standard.stringArray(forKey: "ReportedList") ?? []

        if !reportedList.contains(postID) {
            reportedList.append(postID)
            UserDefaults.standard.set(reportedList, forKey: "ReportedList")
        }
    }

    private func updateReportedPostListInFirebase(postID: String, reason: String) {
        guard let currentUserID = UserDefaults.standard.string(forKey: "userID") else { return }

        let userRef = Firestore.firestore().collection("Users").document(currentUserID)

        userRef.updateData([
            "reportedPostList": FieldValue.arrayUnion([postID])
        ]) { error in
            if error != nil {
            } else {
                print("檢舉貼文已成功更新到 User 的 Firebase")
                self.saveReportedPostToCollection(postID: postID, reporterID: currentUserID, reason: reason)
            }
        }
    }

    private func saveReportedPostToCollection(postID: String, reporterID: String, reason: String) {
        let reportData: [String: Any] = [
            "postID": postID,
            "reporter": reporterID,
            "reason": reason,
            "timestamp": Timestamp() // 加入檢舉的時間
        ]

        let reportsRef = Firestore.firestore().collection("ReportedPosts")
        reportsRef.addDocument(data: reportData) { error in
            if let error = error {
                print("Error saving reported post: \(error)")
            } else {
                print("檢舉資訊已成功存入 ReportedPosts collection")
            }
        }
    }

    // 封鎖
    private func showBlockConfirmation(forUserId userId: String) {
        let alertController = UIAlertController(title: "封鎖用戶", message: "您確定要封鎖這位用戶嗎？", preferredStyle: .alert)

        let confirmAction = UIAlertAction(title: "確定", style: .destructive) { _ in
            self.addToBlockedList(userID: userId)
            self.updateBlockedListInFirebase(userId: userId)
        }

        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)

        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }

    private func addToBlockedList(userID: String) {
        var blockedList = UserDefaults.standard.stringArray(forKey: "BlockedList") ?? []

        if !blockedList.contains(userID) {
            blockedList.append(userID)
            UserDefaults.standard.set(blockedList, forKey: "BlockedList")
        }
    }

    private func updateBlockedListInFirebase(userId: String) {
        guard let currentUserID = UserDefaults.standard.string(forKey: "userID") else { return }

        let userRef = Firestore.firestore().collection("Users").document(currentUserID)

        userRef.updateData([
            "blockedList": FieldValue.arrayUnion([userId])
        ]) { error in
            if error != nil {
            } else {
                print("封鎖名單已成功更新到 Firebase")
            }
        }
    }

    // 留言數量計算
    @objc private func handleCommentCountUpdate(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let postId = userInfo["postId"] as? String,
              let count = userInfo["count"] as? Int else {
            return
        }

        if let index = currentPosts.firstIndex(where: { $0.id == postId }),
           let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? PostCell {
            cell.commentCount.text = "\(count)"
        }
    }
}
