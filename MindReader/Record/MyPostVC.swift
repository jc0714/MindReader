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

class MyPostVC: BasePostVC {

    private var listener: ListenerRegistration?

    private var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchPosts()

        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl)

        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableData), name: NSNotification.Name("DataUpdated"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableData), name: NSNotification.Name("RefreshDataNotification"), object: nil)

        refreshControl.addTarget(self, action: #selector(fetchPosts), for: UIControl.Event.valueChanged)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener?.remove()
    }

    @objc func reloadTableData() {
        fetchPosts()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func fetchPosts() {
        self.posts.removeAll()

        let dispatchGroup = DispatchGroup()
        var commentCounts = [String: Int]()

        guard let userId = UserDefaults.standard.string(forKey: "userID") else {
            print("User ID is nil")
            return
        }

        listener = Firestore.firestore().collection("Users").document(userId).addSnapshotListener { [weak self] (documentSnapshot, error) in
            guard let self = self else { return }
            guard let document = documentSnapshot, document.exists, error == nil else {
                print("Error getting document: \(String(describing: error))")
                self.refreshControl.endRefreshing()
                return
            }

            // 該用戶的文章
            if let postIds = document.data()?["postIds"] as? [String], !postIds.isEmpty {
                // 從 posts collection 撈文章
                Firestore.firestore().collection("posts")
                    .whereField(FieldPath.documentID(), in: postIds)
                    .order(by: "createdTime", descending: true)
                    .getDocuments { (snapshot, error) in
                        guard let snapshot = snapshot, error == nil else {
                            print("Error getting documents: \(String(describing: error))")
                            self.refreshControl.endRefreshing()
                            return
                        }

                        for document in snapshot.documents {
                            let postId = document.documentID
                            dispatchGroup.enter()
                            Firestore.firestore().collection("posts").document(postId).collection("Comments")
                                .getDocuments { querySnapshot, error in
                                    commentCounts[postId] = querySnapshot?.documents.count ?? 0
                                    dispatchGroup.leave()
                                }
                        }

                        dispatchGroup.notify(queue: .main) {
                            self.posts = snapshot.documents.compactMap { document in
                                let data = document.data()
                                guard let avatar = data["avatar"] as? Int,
                                      let title = data["title"] as? String,
                                      let timestamp = data["createdTime"] as? Timestamp,
                                      let category = data["category"] as? String,
                                      let content = data["content"] as? String,
                                      let authorData = data["author"] as? [String: Any],
                                      let authorEmail = authorData["email"] as? String,
                                      let authorId = authorData["id"] as? String,
                                      let authorName = authorData["name"] as? String
                                else { return nil }

                                let like = (data["like"] as? [String])?.count ?? 0
                                let commentCount = commentCounts[document.documentID] ?? 0 // 正確的留言數量

                                let image = data["image"] as? String
                                let createdTimeString = DateFormatter.localizedString(
                                    from: timestamp.dateValue(),
                                    dateStyle: .medium, timeStyle: .none
                                )

                                let author = Author(email: authorEmail, id: authorId, name: authorName)

                                return Post(avatar: avatar, title: title, createdTime: createdTimeString, id: document.documentID, category: category, content: content, image: image, author: author, like: like, comment: commentCount)
                            }

                            DispatchQueue.main.async {
                                print("Post IDs: \(postIds)")
                                self.filterPosts(by: "All")
                                self.tableView.reloadData()
                                self.refreshControl.endRefreshing()
                            }
                        }
                    }
            } else {
                print("No postIds found or postIds array is empty")
                self.posts.removeAll()
                self.filterPosts(by: "All")
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        // 刪除動作
        let deleteAction = UIContextualAction(style: .destructive, title: "刪除") { (action, view, completionHandler) in
            // 執行刪除操作
            self.deletePost(at: indexPath)
            completionHandler(true)
            self.fetchPosts()
        }
        deleteAction.backgroundColor = .pink2

        // 分享動作
        let shareAction = UIContextualAction(style: .normal, title: "分享") { (action, view, completionHandler) in
            // 執行分享操作
            self.sharePost(at: indexPath)
            completionHandler(true)
        }
        shareAction.backgroundColor = .pink3

        // 將兩個動作加到 swipe action configuration 中
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, shareAction])
        return configuration
    }

    func deletePost(at indexPath: IndexPath) {

        guard let userId = UserDefaults.standard.string(forKey: "userID") else {
            print("User ID is nil")
            return
        }

        let postId = posts[indexPath.row].id

        Firestore.firestore().collection("posts").document(postId).delete()

        Firestore.firestore().collection("Users").document(userId).updateData([
            "postIds": FieldValue.arrayRemove([postId])
        ])
    }

    // 分享操作
    func sharePost(at indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)

        UIGraphicsBeginImageContextWithOptions(cell!.bounds.size, false, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            cell?.layer.render(in: context)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let screenshot = image else { return }

        let activityViewController = UIActivityViewController(activityItems: [screenshot], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
}
