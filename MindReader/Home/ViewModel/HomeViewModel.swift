//
//  HomeViewModel.swift
//  MindReader
//
//  Created by J oyce on 2024/10/18.
//

import Foundation
import UIKit
import Combine

class HomeViewModel {

    private let apiService: APIService
    private let firestoreService: FirestoreService

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var response: ([String], [String]) = ([], [])
    @Published var shouldClearRecognizedText = false

    init(apiService: APIService, firestoreService: FirestoreService) {
        self.apiService = apiService
        self.firestoreService = firestoreService
    }

    func submit(data: TranslateData) {
        guard let promptText = (data.selectedTag == 1 ? data.prompt?.trimmingCharacters(in: .whitespacesAndNewlines) : data.recognizedText),
              !promptText.isEmpty else {
            errorMessage = "我沒有讀到文字哦"
            isLoading = false
            return
        }

        isLoading = true

        let formattedPrompt = formatPrompt(promptText, audience: data.audience, replyStyle: data.replyStyle)

        Task {
            do {
                let existingResponse = try await firestoreService.fetchResponse(for: promptText)
                if let existing = existingResponse, let meanings = existing["possible_meanings"] as? [String], let methods = existing["response_methods"] as? [String] {
                    self.response = (meanings, methods)
                    shouldClearRecognizedText = true
                } else {
                    let apiResponse = try await apiService.generateTextResponse(for: formattedPrompt)
                    if let responseData = apiResponse.data(using: .utf8),
                       let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any],
                       let content = json["content"] as? [String: Any],
                       let meanings = content["possible_meanings"] as? [String],
                       let methods = content["response_methods"] as? [String] {
                        self.response = (meanings, methods)
                    }
                    if let imageData = data.selectedImage?.jpegData(compressionQuality: 0.75) {
                        let imageURL = try await firestoreService.uploadImage(imageData: imageData)
                        try await firestoreService.saveToFirestore(prompt: promptText, response: apiResponse, imageURL: imageURL)
                    } else {
                        try await firestoreService.saveToFirestore(prompt: promptText, response: apiResponse, imageURL: nil)
                    }
                }
                shouldClearRecognizedText = true
                isLoading = false
            } catch {
                errorMessage = "網路異常，請確認連線"
                isLoading = false
            }
        }
    }

    private func formatPrompt(_ prompt: String, audience: String?, replyStyle: String?) -> String {
        let finalAudience = audience ?? "不限"
        let finalReplyStyle = replyStyle ?? "不限"

        return """
        你是「另一半翻譯機」，請分析這封訊息的意圖，並針對「該對象」提供「特定風格」的回覆訊息。
        用下方訊息內容分析「possible_meanings：訊息背後隱含意義」和「response_methods：推薦回覆訊息」兩個部分，各三個。

        訊息內容：\(prompt)
        對象：\(finalAudience)
        回覆風格：\(finalReplyStyle)

        用繁體中文，以 JSON 格式：
        "content": {
            "possible_meanings": [
                "",
                "",
                ""
            ],
            "response_methods": [
                "訊息1",
                "訊息2",
                "訊息3"
            ]
        }
        """
    }
}
