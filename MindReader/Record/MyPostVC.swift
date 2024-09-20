//
//  MyPostVC.swift
//  MindReader
//
//  Created by J oyce on 2024/9/20.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore

class MyPostVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let tableView = UITableView()

    private var posts: [Post] = []

    private let firebaseService = FirestoreService()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .color

        setupTableView()
        fetchPosts()
    }

    private func setupTableView() {
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        tableView.register(PostCell.self, forCellReuseIdentifier: "PostCell")

        tableView.delegate = self
        tableView.dataSource = self
    }

    private func fetchPosts() {
        // 該用戶的文章
        Firestore.firestore().collection("Users").document("9Y2GjnVg8TEoze0GUJSU").getDocument { (documentSnapshot, error) in
            guard let document = documentSnapshot, document.exists, error == nil else {
                print("Error getting document: \(String(describing: error))")
                return
            }
            // 從 posts collection 撈文章
            if let postIds = document.data()?["postIds"] as? [String] {
                Firestore.firestore().collection("posts")
                    .whereField(FieldPath.documentID(), in: postIds)
                    .order(by: "createdTime", descending: true)
                    .getDocuments { [weak self] (snapshot, error) in
                        guard let self = self else { return }
                        if let error = error {
                            print("Error getting documents: \(error)")
                            return
                        }
                        guard let snapshot = snapshot else {
                            print("No documents found")
                            return
                        }

                        self.posts.removeAll()

                        for document in snapshot.documents {
                            let data = document.data()
                            guard let title = data["title"] as? String,
                                  let timestamp = data["createdTime"] as? Timestamp,
                                  let category = data["category"] as? String,
                                  let content = data["content"] as? String,
                                  let authorData = data["author"] as? [String: Any],
                                  let authorEmail = authorData["email"] as? String,
                                  let authorId = authorData["id"] as? String,
                                  let authorName = authorData["name"] as? String
                            else {
                                    continue                            }

                            let like = (data["like"] as? [String])?.count ?? 0
                            let commentCount = (data["Comments"] as? [[String: Any]])?.count ?? 0

                            let image = data["image"] as? String

                            let createdTimeString = DateFormatter.localizedString(
                                from: timestamp.dateValue(),
                                dateStyle: .medium, timeStyle: .none
                            )

                            let author = Author(email: authorEmail, id: authorId, name: authorName)

                            let post = Post(title: title, createdTime: createdTimeString, id: document.documentID, category: category, content: content, image: image, author: author, like: like, comment: commentCount)

                            self.posts.append(post)
                        }

                        // 在主線程中刷新表格視圖
                        DispatchQueue.main.async {
                            print("Post IDs: \(postIds)")
                            self.tableView.reloadData()
                        }
                    }
            } else {
                print("No postIds found")
            }
        }
    }

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

        return cell
    }
}
