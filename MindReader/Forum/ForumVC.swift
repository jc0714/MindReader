//
//  ForumVC.swift
//  MindReader
//
//  Created by J oyce on 2024/9/15.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore

class ForumVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    private let firebaseService = FirestoreService()
    var listener: ListenerRegistration?

    var posts: [Post] = []
    private var likedPosts: Set<String> = []

    private let userRef = Firestore.firestore().collection("Users").document("9Y2GjnVg8TEoze0GUJSU")

    var refreshControl: UIRefreshControl!

    private let userId = "9Y2GjnVg8TEoze0GUJSU"

    // MARK: - UI Components
    let goEditButton = UIButton()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        fetchPosts()
        configureTableView()

        loadLikedPosts()

        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl)

        NotificationCenter.default.addObserver(self, selector: #selector(handleCommentCountUpdate(_:)), name: NSNotification.Name("CommentCountUpdated"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableData), name: NSNotification.Name("DataUpdated"), object: nil)

        refreshControl.addTarget(self, action: #selector(fetchPosts), for: UIControl.Event.valueChanged)
    }

    @objc func reloadTableData() {
        fetchPosts()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func fetchPosts() {
        posts.removeAll()
        Firestore.firestore().collection("posts")
            .order(by: "createdTime", descending: true)
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let documents = querySnapshot?.documents, error == nil else {
                    print("Error getting documents: \(String(describing: error))")
                    return
                }

                self?.posts = documents.compactMap { document in
                    let data = document.data()
                    guard let title = data["title"] as? String,
                          let timestamp = data["createdTime"] as? Timestamp,
                          let id = data["id"] as? String,
                          let category = data["category"] as? String,
                          let content = data["content"] as? String,
                          let authorData = data["author"] as? [String: Any],
                          let authorEmail = authorData["email"] as? String,
                          let authorId = authorData["id"] as? String,
                          let authorName = authorData["name"] as? String
                    else { return nil }

                    let like = (data["like"] as? [String])?.count ?? 0
                    let commentCount = (data["Comments"] as? [[String: Any]])?.count ?? 0

                    let image = data["image"] as? String
                    let createdTimeString = DateFormatter.localizedString(
                        from: timestamp.dateValue(),
                        dateStyle: .medium, timeStyle: .none
                    )
                    let author = Author(email: authorEmail, id: authorId, name: authorName)
                    return Post(title: title, createdTime: createdTimeString, id: id, category: category, content: content, image: image, author: author, like: like, comment: commentCount)
                }

                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
    }

    private func loadLikedPosts() {
        userRef.getDocument { [weak self] (document, error) in
            guard let self = self, let document = document, document.exists, let data = document.data() else {
                print("Error fetching liked posts: \(String(describing: error))")
                return
            }

            if let likePosts = data["likePosts"] as? [String] {
                self.likedPosts = Set(likePosts)
            }

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - UITableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell else {
            fatalError("Unable to dequeue PostCell")
        }

        let post = posts[indexPath.row]

        cell.articleTitle.text = post.title
        cell.authorName.text = post.author.name
        cell.createdTimeLabel.text = post.createdTime
        cell.categoryLabel.text = post.category
        cell.contentLabel.text = post.content

        cell.heartCount.text = String(post.like)
        cell.commentCount.text = String(post.comment)

        cell.configure(with: post.image)

        if likedPosts.contains(post.id) {
            cell.heartButton.setImage((UIImage(systemName: "heart.fill")), for: .normal)
        } else {
            cell.heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }

        cell.heartButtonTappedClosure = { [weak self] in
            self?.updateHeartLabel(at: indexPath)
        }

        cell.commentButtonTappedClosure = { [weak self] in
            self?.showCommentsForPost(at: indexPath)
        }
        return cell
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .color
        setupEditButton()
    }

    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(PostCell.self, forCellReuseIdentifier: "PostCell")
    }

    private func setupEditButton() {
        goEditButton.backgroundColor = UIColor.white
        goEditButton.setTitle("➕", for: .normal)
        goEditButton.layer.cornerRadius = 30
        goEditButton.layer.borderColor = UIColor.brown.cgColor
        goEditButton.layer.borderWidth = 3

        goEditButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(goEditButton)

        NSLayoutConstraint.activate([
            goEditButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            goEditButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            goEditButton.widthAnchor.constraint(equalToConstant: 60),
            goEditButton.heightAnchor.constraint(equalToConstant: 60)
        ])

        goEditButton.addTarget(self, action: #selector(navigateToEditPage), for: .touchUpInside)
    }

    // MARK: - Actions
    @objc func navigateToEditPage() {
        performSegue(withIdentifier: "toEditPage", sender: self)
    }

    private func updateHeartLabel(at indexPath: IndexPath) {
        let postId = posts[indexPath.row].id
        let currentUser = "JJ"

        let cell = tableView.cellForRow(at: indexPath) as? PostCell

        Task {
            let postRef = Firestore.firestore().collection("posts").document(postId)

            do {
                // 先獲取當前的貼文資料，檢查 "Likes" 陣列是否包含當前用戶
                let documentSnapshot = try await postRef.getDocument()
                if let data = documentSnapshot.data(), let likes = data["like"] as? [String] {
                    if likes.contains(currentUser) {
                        // 如果當前用戶已經點過讚，則從陣列中移除
                        try await postRef.updateData([
                            "like": FieldValue.arrayRemove([currentUser])
                        ])
                        try await userRef.updateData([
                            "likePosts": FieldValue.arrayRemove([postId])
                        ])

                        cell?.heartButton.setImage((UIImage(systemName: "heart")), for: .normal)
                        cell?.heartCount.text = String(likes.count - 1)
                    } else {
                        // 如果當前用戶未點過讚，則添加到陣列中
                        try await postRef.updateData([
                            "like": FieldValue.arrayUnion([currentUser])
                        ])
                        try await userRef.updateData([
                            "likePosts": FieldValue.arrayUnion([postId])
                        ])
                        cell?.heartButton.setImage((UIImage(systemName: "heart.fill")), for: .normal)
                        cell?.heartCount.text = String(likes.count + 1)
                    }
                }
            } catch {
                print("不給喜歡: \(error.localizedDescription)")
            }
        }
    }

    private func showCommentsForPost(at indexPath: IndexPath) {
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
