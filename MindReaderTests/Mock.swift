//
//  Mock.swift
//  MindReaderTests
//
//  Created by J oyce on 2024/10/22.
//

import Foundation
@testable import MindReader

class MockAPIService: APIService {
    var responseText: String?

    override func generateTextResponse(for prompt: String) async throws -> String {
        if let responseText = responseText {
            return responseText
        } else {
            throw APIError.invalidResponseData
        }
    }
}

class MockFirestoreService: FirestoreService {
    var fetchResponseResult: [String: Any]?

    override func fetchResponse(for prompt: String) async throws -> [String: Any]? {
        return fetchResponseResult
    }

    override func saveToFirestore(prompt: String, response: String, imageURL: String?) async throws {
    }

    override func uploadImage(imageData: Data) async throws -> String {
        return "https://mock.image.url"
    }
}
