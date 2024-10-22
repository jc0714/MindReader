//
//  HomeViewModelTest.swift
//  MindReaderTests
//
//  Created by J oyce on 2024/10/22.
//

import XCTest
import Combine
@testable import MindReader

class HomeViewModelTests: XCTestCase {

    var viewModel: HomeViewModel!
    var mockAPIService: MockAPIService!
    var mockFirestoreService: MockFirestoreService!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockAPIService = MockAPIService()
        mockFirestoreService = MockFirestoreService()
        viewModel = HomeViewModel(apiService: mockAPIService, firestoreService: mockFirestoreService)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockAPIService = nil
        mockFirestoreService = nil
        cancellables = []
        super.tearDown()
    }

    func testSubmit_withValidPrompt_callsAPIAndFirestore() {
        // Arrange
        let expectation = XCTestExpectation(description: "Calls API and Firestore")
        let validPrompt = "有效的翻譯文字"
        let translateData = TranslateData(
            prompt: validPrompt,
            recognizedText: "",
            selectedImage: nil, selectedTag: 1,
            audience: "對象",
            replyStyle: "風格"
        )

        // Mock Firestore 返回 nil（沒有已存在的回應）
        mockFirestoreService.fetchResponseResult = nil

        // Mock APIService 返回回應
        mockAPIService.responseText = """
        {
            "content": {
                "possible_meanings": ["解釋1", "解釋2", "解釋3"],
                "response_methods": ["回覆1", "回覆2", "回覆3"]
            }
        }
        """

        // Act
        viewModel.submit(data: translateData)

        // Assert
        viewModel.responsePublisher
            .sink { response in
                XCTAssertEqual(response.0, ["解釋1", "解釋2", "解釋3"])
                XCTAssertEqual(response.1, ["回覆1", "回覆2", "回覆3"])
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.loadingStatePublisher
            .sink { isLoading in
                XCTAssertFalse(isLoading) // Loading state should be false after completion
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testSubmit_withEmptyPrompt_triggersErrorPublisher() {
        // Arrange
        let expectation = XCTestExpectation(description: "Error triggered due to empty prompt")
        let emptyPrompt = "" // 模擬一個空的 prompt
        let translateData = TranslateData(
            prompt: emptyPrompt, // 空的 prompt
            recognizedText: "",
            selectedImage: nil,
            selectedTag: 1, // 這個標記會讓我們使用 prompt 字段
            audience: "對象",
            replyStyle: "風格"
        )

        // Setup subscriptions before triggering the action
        viewModel.errorPublisher
            .sink { errorMessage in
                XCTAssertEqual(errorMessage, "我沒有讀到文字哦") // 檢查是否正確發送錯誤訊息
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.loadingStatePublisher
            .sink { isLoading in
                XCTAssertFalse(isLoading) // 確保錯誤後載入狀態被正確關閉
            }
            .store(in: &cancellables)

        // Act - trigger submit after setting up subscriptions
        viewModel.submit(data: translateData)

        // Assert
        wait(for: [expectation], timeout: 1.0)
    }

}
