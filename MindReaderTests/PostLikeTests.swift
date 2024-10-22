//
//  PostLikeTests.swift
//  PostLikeTests
//
//  Created by J oyce on 2024/10/19.
//

import XCTest
@testable import MindReader

final class PostLikeTests: XCTestCase {

    var viewController: BasePostVC!

    override func setUpWithError() throws {
        // 初始化 BasePostVC
        viewController = BasePostVC()
    }

    override func tearDownWithError() throws {
        // 測試結束後清理數據
        viewController = nil
    }

    func performLikeAction(_ postId: String, isLiked: Bool, initialLikeCount: Int) throws {
        var mockPosts = [Post(avatar: 1, title: "Test Title", createdTime: "2024-01-01", id: postId, category: "Test Category", content: "Test content", image: "testImageURL", author: Author(email: "", id: "", name: ""), like: initialLikeCount, comment: 0)]
        var mockLikedPosts: Set<String> = isLiked ? [postId] : []

        // 暫時替代原始 VC 的 posts 和 likedPosts
        let originalPosts = viewController.posts
        let originalLikedPosts = BasePostVC.likedPosts

        viewController.posts = mockPosts
        BasePostVC.likedPosts = mockLikedPosts

        // 測試邏輯
        viewController.updatePostLikesLocally(for: postId, isLiked: !isLiked)

        // 確認結果是否正確
        let expectedLikeCount = isLiked ? initialLikeCount - 1 : initialLikeCount + 1
        XCTAssertEqual(viewController.posts[0].like, expectedLikeCount) // 檢查 like 計數是否正確更新

        if isLiked {
            XCTAssertFalse(BasePostVC.likedPosts.contains(postId)) // 檢查 postId 是否從 likedPosts 中移除
        } else {
            XCTAssertTrue(BasePostVC.likedPosts.contains(postId)) // 檢查 postId 是否加入 likedPosts
        }

        // 恢復 VC 原始的 posts 和 likedPosts
        viewController.posts = originalPosts
        BasePostVC.likedPosts = originalLikedPosts
    }

    // 測試按讚
    func testLikePost() throws {
        try performLikeAction("TestPostId", isLiked: false, initialLikeCount: 3)
    }

    // 測試取消按讚
    func testUnlikePost() throws {
        try performLikeAction("TestPostId", isLiked: true, initialLikeCount: 3)
    }

    // 測試多次切換按讚狀態
    func testToggleLikeMultipleTimes() throws {
        let postId = "TestPostId1"
        let initialLikeCount = 0

        // 第一次按：應該增加讚數並標記為已按讚
        try performLikeAction(postId, isLiked: false, initialLikeCount: initialLikeCount)

        // 第二次按：應該取消讚數並從 likedPosts 移除
        try performLikeAction(postId, isLiked: true, initialLikeCount: initialLikeCount + 1)

        // 第三次按：應該再次增加讚數並重新加入 likedPosts
        try performLikeAction(postId, isLiked: false, initialLikeCount: initialLikeCount)
    }
}


//
//final class PostLikeTests: XCTestCase {
//
//    var viewController: BasePostVC!
//
//    override func setUpWithError() throws {
//        // 初始化 BasePostVC
//        viewController = BasePostVC()
//
//        // 清空測試數據
//        viewController.posts = []
//        BasePostVC.likedPosts = []
//    }
//
//    override func tearDownWithError() throws {
//        // 測試結束後清理數據
//        viewController = nil
//        BasePostVC.likedPosts = []
//    }
//
//    func performLikeAction(_ postId: String, isLiked: Bool, initialLikeCount: Int) throws {
//        // Arrange: 準備測試資料
//        let originalPost = Post(avatar: 1, title: "Test Title", createdTime: "2024-01-01", id: postId, category: "Test Category", content: "Test content", image: "testImageURL", author: Author(email: "", id: "", name: ""), like: initialLikeCount, comment: 0)
//        viewController.posts = [originalPost]
//
//        if isLiked {
//            BasePostVC.likedPosts = [postId] // 模擬已按讚的狀況
//        } else {
//            BasePostVC.likedPosts = [] // 模擬未按讚的狀況
//        }
//
//        // Act: 調用 updatePostLikesLocally 函式
//        viewController.updatePostLikesLocally(for: postId, isLiked: !isLiked)
//
//        // Assert: 驗證結果是否正確
//        let expectedLikeCount = isLiked ? initialLikeCount - 1 : initialLikeCount + 1
//        XCTAssertEqual(viewController.posts[0].like, expectedLikeCount) // 檢查 like 計數是否正確更新
//
//        if isLiked {
//            XCTAssertFalse(BasePostVC.likedPosts.contains(postId)) // 檢查 postId 是否從 likedPosts 中移除
//        } else {
//            XCTAssertTrue(BasePostVC.likedPosts.contains(postId)) // 檢查 postId 是否加入 likedPosts
//        }
//    }
//
//    // 測試按一下、兩下、三下
//    func testLikePost() throws {
//        try performLikeAction("TestPostId", isLiked: false, initialLikeCount: 3)
//    }
//
//    func testUnlikePost() throws {
//        try performLikeAction("TestPostId", isLiked: true, initialLikeCount: 3)
//    }
//
//    func testToggleLikeMultipleTimes() throws {
//        let postId = "TestPostId1"
//        let initialLikeCount = 0
//
//        // 第一次按：應該增加讚數並標記為已按讚
//        try performLikeAction(postId, isLiked: false, initialLikeCount: initialLikeCount)
//
//        // 第二次按：應該取消讚數並從 likedPosts 移除
//        try performLikeAction(postId, isLiked: true, initialLikeCount: initialLikeCount + 1)
//
//        // 第三次按：應該再次增加讚數並重新加入 likedPosts
//        try performLikeAction(postId, isLiked: false, initialLikeCount: initialLikeCount)
//    }
//}
