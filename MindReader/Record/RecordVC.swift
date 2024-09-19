//
//  RecordVC.swift
//  MindReader
//
//  Created by J oyce on 2024/9/19.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore

class RecordVC: UIViewController {

    private let firebaseService = FirestoreService()
    var listener: ListenerRegistration?

    var posts: [Post] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // 創建一個按鈕
        let toAlbumutton = UIButton(type: .system)
        toAlbumutton.setTitle("Go to Album", for: .normal)
        toAlbumutton.addTarget(self, action: #selector(fetchPosts), for: .touchUpInside)

        // 按下時的縮放動畫
        toAlbumutton.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        toAlbumutton.addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside])

        // 設置按鈕的外觀
        toAlbumutton.backgroundColor = .pink3
        toAlbumutton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toAlbumutton)

        // 使用 Auto Layout 設置按鈕位置
        NSLayoutConstraint.activate([
            toAlbumutton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toAlbumutton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            toAlbumutton.heightAnchor.constraint(equalToConstant: 50),
            toAlbumutton.widthAnchor.constraint(equalToConstant: 200)
        ])
    }

    @objc func buttonTapped() {
        // 觸發 segue
        performSegue(withIdentifier: "toAlbum", sender: self)
    }

    @objc func buttonTouchDown(sender: UIButton) {
        // 按下時縮放效果
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95) // 稍微縮小
        }
    }

    @objc func buttonTouchUp(sender: UIButton) {
        // 鬆開時恢復原始大小
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform.identity // 恢復到原始大小
        }
    }

    @objc private func fetchPosts() {
        posts.removeAll()
        Firestore.firestore().collection("Users").document("9Y2GjnVg8TEoze0GUJSU").getDocument { (documentSnapshot, error) in
            guard let document = documentSnapshot, document.exists, error == nil else {
                print("Error getting document: \(String(describing: error))")
                return
            }

            if let postIds = document.data()?["postIds"] as? [String] {
                print("Post IDs: \(postIds)")
            } else {
                print("No postIds found")
            }
        }
    }
    // 先到 User -> post
//    @objc private func fetchPosts() {

//        posts.removeAll()
//        Firestore.firestore().collection("posts")
//            .order(by: "createdTime", descending: true)
//            .getDocuments { [weak self] (querySnapshot, error) in
//                guard let documents = querySnapshot?.documents, error == nil else {
//                    print("Error getting documents: \(String(describing: error))")
//                    return
//                }
//
//                self?.posts = documents.compactMap { document in
//                    let data = document.data()
//                    guard let title = data["title"] as? String,
//                          let timestamp = data["createdTime"] as? Timestamp,
//                          let id = data["id"] as? String,
//                          let category = data["category"] as? String,
//                          let content = data["content"] as? String,
//                          let authorData = data["author"] as? [String: Any],
//                          let authorEmail = authorData["email"] as? String,
//                          let authorId = authorData["id"] as? String,
//                          let authorName = authorData["name"] as? String else { return nil }
//
//                    let image = data["image"] as? String
//                    let createdTimeString = DateFormatter.localizedString(
//                        from: timestamp.dateValue(),
//                        dateStyle: .medium, timeStyle: .none
//                    )
//                    let author = Author(email: authorEmail, id: authorId, name: authorName)
//                    return Post(title: title, createdTime: createdTimeString, id: id, category: category, content: content, image: image, author: author)
//                }
//
//                DispatchQueue.main.async {
//                    print(self!.posts)
//                    self?.tableView.reloadData()
//                }
//            }
//    }
}
