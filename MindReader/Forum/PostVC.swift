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
    var filteredPosts: [Post] = []

    static var likedPosts: Set<String> = []

    private let tagFilterView = TagFilterView()

    let imageNames = ["photo4", "photo5", "photo6", "photo7"]

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)

        setupUI()
        loadLikedPosts()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300

        tableView.separatorStyle = .none

        NotificationCenter.default.addObserver(self, selector: #selector(handleCommentCountUpdate(_:)), name: NSNotification.Name("CommentCountUpdated"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(handleLikeUpdate(notification:)), name: NSNotification.Name("LikeCountUpdated"), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("LikeCountUpdated"), object: nil)
    }

    private func setupUI() {
        view.addSubview(tagFilterView) 
        view.addSubview(tableView)

        tagFilterView.translatesAutoresizingMaskIntoConstraints = false

        tagFilterView.tagSelectedClosure = { [weak self] selectedTag in
            self?.filterPosts(by: selectedTag)
        }

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

    func filterPosts(by tag: String) {
        if tag == "All" {
            filteredPosts = posts
        } else {
            filteredPosts = posts.filter { $0.category.contains(tag) }
        }
        tableView.reloadData()
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
                self.filterPosts(by: "All")
            }
        }
    }

    @objc func handleLikeUpdate(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let postId = userInfo["postId"] as? String,
              let newLikes = userInfo["newLikes"] as? Int,
              let isLiked = userInfo["isLiked"] as? Bool,
              let index = posts.firstIndex(where: { $0.id == postId }) else {
            return
        }

        // 更新本地資料
        posts[index].like = newLikes

        // 更新 UI
        DispatchQueue.main.async {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? PostCell {
                cell.heartCount.text = String(newLikes)
                let heartImage = isLiked ? "heart.fill" : "heart"
                cell.heartButton.setImage(UIImage(systemName: heartImage), for: .normal)
            }
        }
    }


    deinit {
        // 移除觀察者
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("RefreshDataNotification"), object: nil)
    }

    // 配置 cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPosts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard indexPath.row < filteredPosts.count else {
            return UITableViewCell()
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell else {
            fatalError("Unable to dequeue PostCell")
        }

        cell.selectionStyle = .none

        let post = filteredPosts[indexPath.row]
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

        cell.setNeedsLayout()
        cell.layoutIfNeeded()

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    // 當點擊 post 時跳轉到這個貼文頁面
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < filteredPosts.count else {
            return
        }

        let selectedPost = filteredPosts[indexPath.row]
        let detailVC = DetailVC()
        detailVC.post = selectedPost // 將所選的 post 資料傳遞到 DetailVC
        navigationController?.pushViewController(detailVC, animated: true)
    }

    // 更新愛心實心空心狀態
    func updateHeartBtn(at indexPath: IndexPath) {
        guard let userId = UserDefaults.standard.string(forKey: "userID") else {
            print("User ID is nil")
            return
        }

        let userRef = Firestore.firestore().collection("Users").document(userId)
        var post = posts[indexPath.row]
        let postId = post.id

        // 批次寫入操作
        let batch = Firestore.firestore().batch()
        let postRef = Firestore.firestore().collection("posts").document(postId)

        var isLiked = false

        if BasePostVC.likedPosts.contains(postId) {
            // 移除愛心
            batch.updateData(["like": FieldValue.arrayRemove([userId])], forDocument: postRef)
            batch.updateData(["likePosts": FieldValue.arrayRemove([postId])], forDocument: userRef)
            BasePostVC.likedPosts.remove(postId)
            post.like -= 1
            isLiked = false
        } else {
            // 添加愛心
            batch.updateData(["like": FieldValue.arrayUnion([userId])], forDocument: postRef)
            batch.updateData(["likePosts": FieldValue.arrayUnion([postId])], forDocument: userRef)
            BasePostVC.likedPosts.insert(postId)
            post.like += 1
            isLiked = true
        }

        // 提交批次寫入操作
        Task {
            do {
                try await batch.commit()

                // 發送通知，將新的愛心狀態（是否按讚）傳遞過去
                NotificationCenter.default.post(name: NSNotification.Name("LikeCountUpdated"), object: nil, userInfo: ["postId": postId, "newLikes": post.like, "isLiked": isLiked])
            } catch {
                print("Error updating likes: \(error.localizedDescription)")
            }
        }
    }

//    func updateHeartBtn(at indexPath: IndexPath) {
//        guard let userId = UserDefaults.standard.string(forKey: "userID") else {
//            print("User ID is nil")
//            return
//        }
//
//        let userRef = Firestore.firestore().collection("Users").document(userId)
//        var post = posts[indexPath.row]
//        let postId = post.id
////        let cell = tableView.cellForRow(at: indexPath) as? PostCell
//
//        // 批次寫入操作
//        let batch = Firestore.firestore().batch()
//        let postRef = Firestore.firestore().collection("posts").document(postId)
//
//        if BasePostVC.likedPosts.contains(postId) {
//            // 移除愛心
//            batch.updateData(["like": FieldValue.arrayRemove([userId])], forDocument: postRef)
//            batch.updateData(["likePosts": FieldValue.arrayRemove([postId])], forDocument: userRef)
//            BasePostVC.likedPosts.remove(postId)
//        } else {
//            // 添加愛心
//            batch.updateData(["like": FieldValue.arrayUnion([userId])], forDocument: postRef)
//            batch.updateData(["likePosts": FieldValue.arrayUnion([postId])], forDocument: userRef)
//            BasePostVC.likedPosts.insert(postId)
//        }
//
//        // 提交批次寫入操作
//        Task {
//            do {
//                try await batch.commit()
//                // 上傳成功後發送通知，並將更新後的愛心數量傳遞過去
//                let newLikes = BasePostVC.likedPosts.contains(postId) ? post.like + 1 : post.like - 1
//                NotificationCenter.default.post(name: NSNotification.Name("LikeCountUpdated"), object: nil, userInfo: ["postId": postId, "newLikes": newLikes])
//            } catch {
//                print("Error updating likes: \(error.localizedDescription)")
//            }
//        }
//    }

//    func updateHeartBtn(at indexPath: IndexPath) {
//
//        guard let userId = UserDefaults.standard.string(forKey: "userID") else {
//            print("User ID is nil")
//            return
//        }
//
//        let userRef = Firestore.firestore().collection("Users").document(userId)
//        
//        var post = posts[indexPath.row]
//        let postId = post.id
//        let cell = tableView.cellForRow(at: indexPath) as? PostCell
//
//        // 批次寫入操作
//        let batch = Firestore.firestore().batch()
//        let postRef = Firestore.firestore().collection("posts").document(postId)
//
//        if BasePostVC.likedPosts.contains(postId) {
//            // 如果用戶已經按了讚，則移除讚
//            batch.updateData(["like": FieldValue.arrayRemove([userId])], forDocument: postRef)
//            batch.updateData(["likePosts": FieldValue.arrayRemove([postId])], forDocument: userRef)
//
//            // 更新本地數據，移除已按讚的文章
//            BasePostVC.likedPosts.remove(postId)
////            post.like -= 1
////            cell?.heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
//        } else {
//            // 如果用戶還未按讚，則添加讚
//            batch.updateData(["like": FieldValue.arrayUnion([userId])], forDocument: postRef)
//            batch.updateData(["likePosts": FieldValue.arrayUnion([postId])], forDocument: userRef)
//
//            // 更新本地數據，添加已按讚的文章
//            BasePostVC.likedPosts.insert(postId)
////            post.like += 1
////            cell?.heartButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
//        }
////        posts[indexPath.row] = post
//
//        // 更新愛心數量顯示
////        cell?.heartCount.text = String(post.like)
//
//        // 提交批次寫入操作
//        Task {
//            do {
//                try await batch.commit()
//                NotificationCenter.default.post(name: NSNotification.Name("LikeCountUpdated"), object: nil, userInfo: ["postId": postId, "newLikes": post.like])
//            } catch {
//                print("Error updating likes: \(error.localizedDescription)")
//            }
//        }
//    }

    // 連結到留言 VC
    func showCommentsForPost(at indexPath: IndexPath) {
        let commentsVC = CommentsVC(postId: posts[indexPath.row].id)
        if let sheet = commentsVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(commentsVC, animated: true, completion: nil)
    }

    // 留言數量計算
    @objc private func handleCommentCountUpdate(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let postId = userInfo["postId"] as? String,
              let count = userInfo["count"] as? Int else {
            return
        }

        if let index = posts.firstIndex(where: { $0.id == postId }),
           let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? PostCell {
            cell.commentCount.text = "\(count)"
        }
    }
}

//                NotificationCenter.default.post(name: NSNotification.Name("RefreshDataNotification"), object: nil, userInfo: ["postId": postId, "newLikes": post.like])

//                NotificationCenter.default.post(name: NSNotification.Name("RefreshDataNotification"), object: nil)
