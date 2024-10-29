//
//  PostLikeTests.swift
//  PostLikeTests
//
//  Created by J oyce on 2024/10/19.
//

import XCTest
@testable import MindReader

//class MockLikeStorage: LikeStorage {
//    var likedPosts = Set<String>()
//}
//
//class LikeManagerTests: XCTestCase {
//
//    var likeManager: LikeManager!
//    var mockStorage: MockLikeStorage!
//
//    override func setUp() {
//        super.setUp()
//        // 使用 MockLikeStorage 作為依賴注入
//        mockStorage = MockLikeStorage()
//        likeManager = LikeManager(storage: mockStorage)
//    }
//
//    func testUpdatePostLikesLocally_WhenAlreadyLiked_RemoveLike() {
//        let postId = "testPost"
//        // 模擬已經按過讚
//        mockStorage.likedPosts.insert(postId)
//        XCTAssertTrue(mockStorage.likedPosts.contains(postId))
//
//        // 取消讚
//        likeManager.updatePostLikesLocally(for: postId, isLiked: false)
//
//        // 驗證 postId 被移除
//        XCTAssertFalse(mockStorage.likedPosts.contains(postId))
//    }
//
//    func testUpdatePostLikesLocally_WhenNotLiked_AddLike() {
//        let postId = "testPost"
//        // 確保初始狀態是未按讚
//        XCTAssertFalse(mockStorage.likedPosts.contains(postId))
//
//        // 按讚
//        likeManager.updatePostLikesLocally(for: postId, isLiked: true)
//
//        // 驗證 postId 被添加
//        XCTAssertTrue(mockStorage.likedPosts.contains(postId))
//    }
//
//    func testUpdatePostLikesLocally_WhenTappedThreeTimes() {
//        let postId = "testPost"
//
//        // 快速按三下，按下、取消、按下
//        likeManager.updatePostLikesLocally(for: postId, isLiked: true)
//        XCTAssertTrue(mockStorage.likedPosts.contains(postId), "應該包含 postId，因為已按讚")
//
//        likeManager.updatePostLikesLocally(for: postId, isLiked: false)
//        XCTAssertFalse(mockStorage.likedPosts.contains(postId), "應該不包含 postId，因為取消了讚")
//
//        likeManager.updatePostLikesLocally(for: postId, isLiked: true)
//        XCTAssertTrue(mockStorage.likedPosts.contains(postId), "應該包含 postId，因為再次按讚")
//    }
//}
