//
//  PostManager.swift
//  MindReader
//
//  Created by J oyce on 2024/9/25.
//

//import FirebaseFirestore
//import UIKit
//
//class PostManager {
//
//    static let shared = PostManager()
//
//    private init() {}
//
//    // 更新按讚狀態的方法
//    func updateHeartBtn(for post: inout Post, postId: String, userRef: DocumentReference, userId: String, at indexPath: IndexPath, in tableView: UITableView) {
//        let cell = tableView.cellForRow(at: indexPath) as? PostCell
//
//        let batch = Firestore.firestore().batch()
//        let postRef = Firestore.firestore().collection("posts").document(postId)
//
//        if BasePostVC.likedPosts.contains(postId) {
//            // 移除讚
//            batch.updateData(["like": FieldValue.arrayRemove([userId])], forDocument: postRef)
//            batch.updateData(["likePosts": FieldValue.arrayRemove([postId])], forDocument: userRef)
//
//            BasePostVC.likedPosts.remove(postId)
//            post.like -= 1
//            cell?.heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
//        } else {
//            // 添加讚
//            batch.updateData(["like": FieldValue.arrayUnion([userId])], forDocument: postRef)
//            batch.updateData(["likePosts": FieldValue.arrayUnion([postId])], forDocument: userRef)
//
//            BasePostVC.likedPosts.insert(postId)
//            post.like += 1
//            cell?.heartButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
//        }
//
//        // 更新愛心數量顯示
//        cell?.heartCount.text = String(post.like)
//
//        // 提交批次寫入操作
//        Task {
//            do {
//                try await batch.commit()
//                NotificationCenter.default.post(name: NSNotification.Name("RefreshDataNotification"), object: nil)
//            } catch {
//                print("Error updating likes: \(error.localizedDescription)")
//            }
//        }
//    }
//
//    // 處理評論數更新
//    func handleCommentCountUpdate(for post: inout Post, _ notification: Notification, in tableView: UITableView) {
//        guard let userInfo = notification.userInfo,
//              let postId = userInfo["postId"] as? String,
//              let newCommentCount = userInfo["count"] as? Int else {
//            return
//        }
//
//        if post.id == postId {
//            post.comment = newCommentCount
//            DispatchQueue.main.async {
//                if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PostCell {
//                    cell.commentCount.text = "\(newCommentCount)"
//                }
//            }
//        }
//    }
//}
