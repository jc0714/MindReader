//
//  MindReaderTests.swift
//  MindReaderTests
//
//  Created by J oyce on 2024/10/19.
//

import XCTest
@testable import MindReader

final class MindReaderTests: XCTestCase {

    var viewController: BasePostVC!

    override func setUpWithError() throws {
        // 初始化 BasePostVC
        viewController = BasePostVC()

        // 清空測試數據
        viewController.posts = []
        BasePostVC.likedPosts = []
    }

    override func tearDownWithError() throws {
        // 測試結束後清理數據
        viewController = nil
        BasePostVC.likedPosts = []
    }

    func testUpdatePostLikesLocally_withPostId(_ postId: String, isLiked: Bool, initialLikeCount: Int) throws {
        // Arrange: 準備測試資料
        let originalPost = Post(avatar: 1, title: "Test Title", createdTime: "2024-01-01", id: postId, category: "Test Category", content: "Test content", image: "testImageURL", author: Author(email: "", id: "", name: ""), like: initialLikeCount, comment: 0)
        viewController.posts = [originalPost]

        if isLiked {
            BasePostVC.likedPosts = [postId] // 模擬已按讚的狀況
        } else {
            BasePostVC.likedPosts = [] // 模擬未按讚的狀況
        }

        // Act: 調用 updatePostLikesLocally 函式
        viewController.updatePostLikesLocally(for: postId, isLiked: !isLiked)

        // Assert: 驗證結果是否正確
        let expectedLikeCount = isLiked ? initialLikeCount - 1 : initialLikeCount + 1
        XCTAssertEqual(viewController.posts[0].like, expectedLikeCount) // 檢查 like 計數是否正確更新

        if isLiked {
            XCTAssertFalse(BasePostVC.likedPosts.contains(postId)) // 檢查 postId 是否從 likedPosts 中移除
        } else {
            XCTAssertTrue(BasePostVC.likedPosts.contains(postId)) // 檢查 postId 是否加入 likedPosts
        }
    }

    func testLikePost() throws {
        try testUpdatePostLikesLocally_withPostId("TestPostId1", isLiked: false, initialLikeCount: 3)
    }

    func testUnlikePost() throws {
        try testUpdatePostLikesLocally_withPostId("TestPostId2", isLiked: true, initialLikeCount: 3)
    }
}
