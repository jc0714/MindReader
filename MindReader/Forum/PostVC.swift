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

    private let userId = "9Y2GjnVg8TEoze0GUJSU"
    private let userRef = Firestore.firestore().collection("Users").document("9Y2GjnVg8TEoze0GUJSU")

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)

        setupUI()
        loadLikedPosts()

//        filterPosts(by: "All")

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300

        NotificationCenter.default.addObserver(self, selector: #selector(handleCommentCountUpdate(_:)), name: NSNotification.Name("CommentCountUpdated"), object: nil)

    }

    // 配置 TableView
//    private func setupTableView() {
//        view.addSubview(tableView)
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//        ])
//        tableView.register(PostCell.self, forCellReuseIdentifier: "PostCell")
//        tableView.delegate = self
//        tableView.dataSource = self
//    }

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

    private func filterPosts(by tag: String) {
        if tag == "All" {
            filteredPosts = posts
        } else {
            filteredPosts = posts.filter { $0.category.contains(tag) }
        }
        tableView.reloadData()
    }

    // 初始化的時候把按過讚的愛心填滿
    private func loadLikedPosts() {
        userRef.getDocument { [weak self] (document, error) in
            guard let self = self, let document = document, document.exists, let data = document.data() else {
                print("Error fetching liked posts: \(String(describing: error))")
                return
            }
            if let likePosts = data["likePosts"] as? [String] {
                BasePostVC.likedPosts = Set(likePosts)
            }
            DispatchQueue.main.async {
                self.filterPosts(by: "All")
                self.tableView.reloadData()
            }
        }
    }

    // 配置 cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPosts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

        cell.authorTapAction = { [weak self] in
            self?.fetchPostsByAuthor(authorId: post.author.id)
        }

        cell.setNeedsLayout()
        cell.layoutIfNeeded()

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func fetchPostsByAuthor(authorId: String) {
        print("Author TAPPEDDD")
    }

    // 當點擊 post 時跳轉到詳細頁面
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPost = posts[indexPath.row]
        let detailVC = DetailVC()
        detailVC.post = selectedPost // 將所選的 post 資料傳遞到 DetailVC
        navigationController?.pushViewController(detailVC, animated: true)
    }

    // 更新愛心實心空心狀態
    func updateHeartBtn(at indexPath: IndexPath) {
        //        var post = posts[indexPath.row]
        //        PostManager.shared.updateHeartBtn(for: &post, postId: post.id, userRef: userRef, userId: userId, at: indexPath, in: tableView)
        //    }
        var post = posts[indexPath.row]
        let postId = post.id
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
            post.like -= 1
            cell?.heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
        } else {
            // 如果用戶還未按讚，則添加讚
            batch.updateData(["like": FieldValue.arrayUnion([userId])], forDocument: postRef)
            batch.updateData(["likePosts": FieldValue.arrayUnion([postId])], forDocument: userRef)

            // 更新本地數據，添加已按讚的文章
            BasePostVC.likedPosts.insert(postId)
            post.like += 1
            cell?.heartButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }

        // 更新愛心數量顯示
        cell?.heartCount.text = String(post.like)

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

    // 連結到留言 VC
    func showCommentsForPost(at indexPath: IndexPath) {
        let commentsVC = CommentsVC(postId: posts[indexPath.row].id)
        if let sheet = commentsVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(commentsVC, animated: true, completion: nil)
    }

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

//    @objc private func handleCommentCountUpdate(_ notification: Notification) {
//        guard let postIndex = posts.firstIndex(where: { $0.id == notification.userInfo?["postId"] as? String }) else { return }
//        PostManager.shared.handleCommentCountUpdate(for: &posts[postIndex], notification, in: tableView)
//    }
