//
//  PostLikeManager.swift
//  MindReader
//
//  Created by J oyce on 2024/10/19.
//

import Foundation

class LikeManager {
    static let shared = LikeManager()

    private init() {}

    // 更新本地的愛心數量
    func updatePostLikesLocally(for postId: String, isLiked: Bool, posts: inout [Post]) {
        if let originalIndex = posts.firstIndex(where: { $0.id == postId }) {
            posts[originalIndex].like += isLiked ? 1 : -1
        }
        if isLiked {
            BasePostVC.likedPosts.insert(postId)
        } else {
            BasePostVC.likedPosts.remove(postId)
        }
    }
}
