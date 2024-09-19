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

    // MARK: - UI Components
    let goEditButton = UIButton()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupFirestoreListener()
        configureTableView()

        NotificationCenter.default.addObserver(self, selector: #selector(handleCommentCountUpdate(_:)), name: NSNotification.Name("CommentCountUpdated"), object: nil)
    }

    // MARK: - Firestore
    private func setupFirestoreListener() {
        listener = firebaseService.setupFirestoreListener(for: "posts") { [weak self] in
            self?.fetchPosts()
        }
    }

    private func fetchPosts() {
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
                          let authorName = authorData["name"] as? String else { return nil }

                    let image = data["image"] as? String
                    let createdTimeString = DateFormatter.localizedString(
                        from: timestamp.dateValue(),
                        dateStyle: .medium, timeStyle: .none
                    )
                    let author = Author(email: authorEmail, id: authorId, name: authorName)
                    return Post(title: title, createdTime: createdTimeString, id: id, category: category, content: content, image: image, author: author)
                }

                DispatchQueue.main.async {
                    self?.tableView.reloadData()
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

        cell.configure(with: post.image)

        cell.commentButtonTappedClosure = { [weak self] in
            self?.showCommentsForPost(at: indexPath)
        }
        cell.commentButtonLongPressClosure = { [weak self] in
            self?.showTextFieldForComment(at: indexPath)
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

    private func showCommentsForPost(at indexPath: IndexPath) {
        let commentsVC = CommentsVC(postId: posts[indexPath.row].id)

        if let sheet = commentsVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(commentsVC, animated: true, completion: nil)
    }

    private func showTextFieldForComment(at indexPath: IndexPath) {
        let postId = posts[indexPath.row].id

        let alert = UIAlertController(title: "歡迎留言", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "請輸入留言"
        }

        let submitAction = UIAlertAction(title: "送出", style: .default) { [weak self] _ in
            guard let textField = alert.textFields?.first, let commentText = textField.text, !commentText.isEmpty else {
                print("留言不能為空")
                return
            }

            Task {
                let postRef = Firestore.firestore().collection("posts").document(postId)
                let newComment: [String: Any] = [
                    "id": UUID().uuidString,
                    "author": "JJ",
                    "authorId": "JJCC",
                    "content": commentText,
                    "timestamp": Timestamp(date: Date())
                ]

                do {
                    try await postRef.updateData([
                        "Comments": FieldValue.arrayUnion([newComment])
                    ])
                    print("留言已成功提交")
                } catch {
                    print("留言提交失敗: \(error.localizedDescription)")
                }
            }
        }

        alert.addAction(submitAction)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    @objc private func handleCommentCountUpdate(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let postId = userInfo["postId"] as? String,
              let count = userInfo["count"] as? Int else {
            return
        }

        // 更新對應的 postCell
        if let index = posts.firstIndex(where: { $0.id == postId }),
           let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? PostCell {
            cell.commentCount.text = "\(count)"
        }
    }
}
