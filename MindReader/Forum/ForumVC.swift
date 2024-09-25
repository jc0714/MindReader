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

class ForumVC: BasePostVC {

    let goEditButton = UIButton()

    private var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()

//        setupUI()

        fetchPosts()

        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl)

        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableData), name: NSNotification.Name("DataUpdated"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableData), name: NSNotification.Name("RefreshDataNotification"), object: nil)

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
                self?.refreshControl.endRefreshing()
                return
            }

            self?.posts = documents.compactMap { document in
                let data = document.data()
                guard let avatar = data["avatar"] as? Int,
                      let title = data["title"] as? String,
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

                let date = timestamp.dateValue()
                let createdTimeString = DateFormatter.yyyyMMddFormatter.string(from: date)

                let author = Author(email: authorEmail, id: authorId, name: authorName)
                return Post(avatar: avatar, title: title, createdTime: createdTimeString, id: id, category: category, content: content, image: image, author: author, like: like, comment: commentCount)
            }

            DispatchQueue.main.async {
                self?.setupUI()
                self?.tableView.reloadData()
                self?.refreshControl.endRefreshing()
            }
        }
    }

    private func setupUI() {
        view.backgroundColor = .color
        setupEditButton()
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

    @objc func navigateToEditPage() {
        performSegue(withIdentifier: "toEditPage", sender: self)
    }
}
