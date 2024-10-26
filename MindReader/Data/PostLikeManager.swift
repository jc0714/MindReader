//
//  PostLikeManager.swift
//  MindReader
//
//  Created by J oyce on 2024/10/19.
//

import Foundation
import Firebase

class LikeManager {
    static let shared = LikeManager()

    private init() {}

    // 更新本地的愛心數量
    func updatePostLikesLocally(for postId: String, isLiked: Bool) {
        if isLiked {
            BasePostVC.likedPosts.insert(postId)
        } else {
            BasePostVC.likedPosts.remove(postId)
        }
    }

    func toggleLike(postId: String, userId: String) async throws -> Bool {
        let batch = Firestore.firestore().batch()
        let postRef = Firestore.firestore().collection("posts").document(postId)
        let userRef = Firestore.firestore().collection("Users").document(userId)

        var isLiked = false

        if await BasePostVC.likedPosts.contains(postId) {
            // 移除愛心
            batch.updateData(["like": FieldValue.arrayRemove([userId])], forDocument: postRef)
            batch.updateData(["likePosts": FieldValue.arrayRemove([postId])], forDocument: userRef)
            isLiked = false
        } else {
            // 添加愛心
            batch.updateData(["like": FieldValue.arrayUnion([userId])], forDocument: postRef)
            batch.updateData(["likePosts": FieldValue.arrayUnion([postId])], forDocument: userRef)
            isLiked = true
        }

        // 提交批次寫入操作
        try await batch.commit()

        // 更新本地愛心狀態
        updatePostLikesLocally(for: postId, isLiked: isLiked)

        return isLiked
    }
}
