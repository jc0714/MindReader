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
import Lottie

class ForumVC: BasePostVC {

    let goEditButton = UIButton()

    private var refreshControl: UIRefreshControl!
//    private var lottieAnimationView: LottieAnimationView!

    private let tag = "All"

    override func viewDidLoad() {
        super.viewDidLoad()

        self.VCid = "ForumVC"
//        setupRefreshControl()

        fetchPosts()
//
        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl)

        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableData), name: NSNotification.Name("NewPostAdded"), object: nil)

        refreshControl.addTarget(self, action: #selector(fetchPosts), for: UIControl.Event.valueChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: false)

        navigationController?.navigationBar.isHidden = true

        fetchPosts()
    }
//
//    func setupRefreshControl() {
//        refreshControl = UIRefreshControl()
//        refreshControl.tintColor = .clear // Hide default spinner
//
//        // Create Lottie animation view
//        lottieAnimationView = LottieAnimationView(name: "refreshing")
//        lottieAnimationView.frame = CGRect(x: 0, y: 0, width: 300, height: 50)
//        lottieAnimationView.contentMode = .scaleAspectFit
//        lottieAnimationView.loopMode = .loop
//
//        // Add Lottie animation to refresh control
//        refreshControl.addSubview(lottieAnimationView)
//        lottieAnimationView.center = refreshControl.center
//
//        // Add target for refresh control
//        refreshControl.addTarget(self, action: #selector(fetchPosts), for: .valueChanged)
//        tableView.addSubview(refreshControl)
//    }

    @objc func reloadTableData() {
        fetchPosts()
    }

    @objc private func fetchPosts() {
//        lottieAnimationView.play()

        posts.removeAll()
        let dispatchGroup = DispatchGroup()
        var commentCounts = [String: Int]() // 用來儲存每篇貼文的評論數量

        let blockedList = UserDefaults.standard.stringArray(forKey: "BlockedList") ?? []
        let reportedList = UserDefaults.standard.stringArray(forKey: "ReportedList") ?? []

        Firestore.firestore().collection("posts")
            .order(by: "createdTime", descending: true)
        .getDocuments { [weak self] (querySnapshot, error) in
            guard let documents = querySnapshot?.documents, error == nil else {
                print("Error getting documents: \(String(describing: error))")
                self?.refreshControl.endRefreshing()
                return
            }

            for document in documents {
                let postId = document.documentID

                dispatchGroup.enter()

                Firestore.firestore().collection("posts").document(postId).collection("Comments")
                    .getDocuments { querySnapshot, error in
                        commentCounts[postId] = querySnapshot?.documents.count ?? 0
                        dispatchGroup.leave()
                    }
            }

            dispatchGroup.notify(queue: .main) {
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

                    if blockedList.contains(authorId) || reportedList.contains(id) {
                        return nil
                    }

                    let like = (data["like"] as? [String])?.count ?? 0
                    let image = data["image"] as? String
                    let date = timestamp.dateValue()
                    let createdTimeString = DateFormatter.yyyyMMddFormatter.string(from: date)
                    let author = Author(email: authorEmail, id: authorId, name: authorName)
                    let commentCount = commentCounts[id] ?? 0

                    return Post(avatar: avatar, title: title, createdTime: createdTimeString, id: id, category: category, content: content, image: image, author: author, like: like, comment: commentCount)
                }
                self?.setupUI()
                self?.tableView.reloadData()
//                self?.lottieAnimationView.stop()
                self?.refreshControl.endRefreshing()
            }
        }
    }

    private func setupUI() {
        view.backgroundColor = .milkYellow
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
