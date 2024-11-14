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

        mockFirestoreService.fetchResponseResult = nil

        mockAPIService.responseText = """
        {
            "content": {
                "possible_meanings": ["解釋1", "解釋2", "解釋3"],
                "response_methods": ["回覆1", "回覆2", "回覆3"]
            }
        }
        """

        viewModel.$response
            .dropFirst()
            .sink { response in
                XCTAssertEqual(response.0, ["解釋1", "解釋2", "解釋3"])
                XCTAssertEqual(response.1, ["回覆1", "回覆2", "回覆3"])
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.$isLoading
        .sink { isLoading in
            if !isLoading {
                expectation.fulfill()
            }
        }
        .store(in: &cancellables)

        viewModel.submit(data: translateData)

        wait(for: [expectation], timeout: 2.0)
    }

    func testSubmit_withEmptyPrompt_triggersErrorPublisher() {
        // Arrange
        let expectation = XCTestExpectation(description: "Error triggered due to empty prompt")
        let emptyPrompt = ""
        let translateData = TranslateData(
            prompt: emptyPrompt,
            recognizedText: "",
            selectedImage: nil,
            selectedTag: 1,
            audience: "對象",
            replyStyle: "風格"
        )

        viewModel.$errorMessage
            .dropFirst()
            .sink { errorMessage in
                XCTAssertEqual(errorMessage, "我沒有讀到文字哦")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .sink { isLoading in
                XCTAssertFalse(isLoading)
            }
            .store(in: &cancellables)

        viewModel.submit(data: translateData)

        wait(for: [expectation], timeout: 1.0)
    }
}
