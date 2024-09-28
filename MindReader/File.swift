//
//  File.swift
//  MindReader
//
//  Created by J oyce on 2024/9/28.
//

import Foundation
import Firebase

//func fetchPosts(completion: @escaping () -> Void) {
//    let db = Firestore.firestore()
//    db.collection("posts").getDocuments { [weak self] (snapshot, error) in
//        guard let self = self, let documents = snapshot?.documents, error == nil else {
//            print("Error fetching posts: \(error?.localizedDescription ?? "Unknown error")")
//            completion()
//            return
//        }
//
//        // 清空 posts
//        self.posts = []
//
//        // 遍历每个帖子文档
//        for document in documents {
//            let data = document.data()
//
//            guard let avatar = data["avatar"] as? Int,
//                  let title = data["title"] as? String,
//                  let timestamp = data["createdTime"] as? Timestamp,
//                  let id = data["id"] as? String,
//                  let category = data["category"] as? String,
//                  let content = data["content"] as? String,
//                  let authorData = data["author"] as? [String: Any],
//                  let authorEmail = authorData["email"] as? String,
//                  let authorId = authorData["id"] as? String,
//                  let authorName = authorData["name"] as? String else {
//                continue
//            }
//
//            let like = (data["like"] as? [String])?.count ?? 0
//            let image = data["image"] as? String
//            let date = timestamp.dateValue()
//            let createdTimeString = DateFormatter.yyyyMMddFormatter.string(from: date)
//            let author = Author(email: authorEmail, id: authorId, name: authorName)
//
//            // 获取评论数量
//            let commentsRef = document.reference.collection("comments")
//            commentsRef.getDocuments { (snapshot, error) in
//                var commentCount = 0
//                if let error = error {
//                    print("Error fetching comment count: \(error.localizedDescription)")
//                } else {
//                    commentCount = snapshot?.documents.count ?? 0
//                }
//
//                // 构建 Post 对象并添加到 posts 数组
//                let post = Post(avatar: avatar, title: title, createdTime: createdTimeString, id: id, category: category, content: content, image: image, author: author, like: like, comment: commentCount)
//                self.posts.append(post)
//
//                // 检查是否已经处理完所有文档
//                if self.posts.count == documents.count {
//                    // 在主线程更新 UI
//                    DispatchQueue.main.async {
//                        completion()
//                    }
//                }
//            }
//        }
//    }
//}
