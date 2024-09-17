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

    let goEditButton = UIButton()

    var posts: [Post] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .color

        listener = firebaseService.setupFirestoreListener(for: "posts") {
            self.fetchPosts()
        }

        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100

        tableView.register(PostCell.self, forCellReuseIdentifier: "PostCell")

        setUI()
    }

    func fetchPosts() {
        posts.removeAll()
        let db = Firestore.firestore()

        db.collection("posts")
            .order(by: "createdTime", descending: true)
            .getDocuments { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents, error == nil else {
                    print("Error getting documents: \(String(describing: error))")
                    return
                }

                documents.forEach { document in
                    let data = document.data()

                    if let title = data["title"] as? String,
                       let timestamp = data["createdTime"] as? Timestamp,
                       let id = data["id"] as? String,
                       let category = data["category"] as? String,
                       let content = data["content"] as? String,
                       let authorData = data["author"] as? [String: Any],
                       let authorEmail = authorData["email"] as? String,
                       let authorId = authorData["id"] as? String,
                       let authorName = authorData["name"] as? String {

                        let image = data["image"] as? String

                        let createdTimeString = DateFormatter.localizedString(
                            from: timestamp.dateValue(),
                            dateStyle: .medium,
                            timeStyle: .none
                        )

                        let author = Author(email: authorEmail, id: authorId, name: authorName)
                        let post = Post(title: title, createdTime: createdTimeString, id: id, category: category, content: content, image: image, author: author)
                        self.posts.append(post)
                    }
                }

                DispatchQueue.main.async {
                    self.tableView.reloadData()
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

    func setUI() {
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
        goEditButton.addTarget(self, action: #selector(click), for: .touchUpInside)
    }

    @objc func click(_ sender: UIButton) {
        performSegue(withIdentifier: "toEditPage", sender: self)
    }
}
