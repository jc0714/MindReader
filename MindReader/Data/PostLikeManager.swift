//
//  PostLikeManager.swift
//  MindReader
//
//  Created by J oyce on 2024/10/19.
//

import Foundation
import Firebase
import UIKit

class PostLikeManager {
    static let shared = PostLikeManager()

    private init() {}

    func configureBatchOperation(_ batch: WriteBatch, isLiked: Bool, userId: String, postId: String) {
        let postRef = Firestore.firestore().collection("posts").document(postId)
        let userRef = Firestore.firestore().collection("Users").document(userId)

        if isLiked {
            // 移除愛心
            batch.updateData(["like": FieldValue.arrayRemove([userId])], forDocument: postRef)
            batch.updateData(["likePosts": FieldValue.arrayRemove([postId])], forDocument: userRef)
        } else {
            // 添加愛心
            batch.updateData(["like": FieldValue.arrayUnion([userId])], forDocument: postRef)
            batch.updateData(["likePosts": FieldValue.arrayUnion([postId])], forDocument: userRef)
        }
    }
}
