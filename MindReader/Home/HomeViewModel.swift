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

    // 使用 Combine 的 Subject
    var loadingStatePublisher = PassthroughSubject<Bool, Never>()
    var responsePublisher = PassthroughSubject<([String], [String]), Never>()
    var errorPublisher = PassthroughSubject<String, Never>()

//    var onLoadingStateChange: ((Bool) -> Void)?
//    var onResponseReceived: (([String], [String]) -> Void)?
//    var onErrorOccurred: ((String) -> Void)?

    init(apiService: APIService, firestoreService: FirestoreService) {
        self.apiService = apiService
        self.firestoreService = firestoreService
    }

    func submit(data: TranslateData) {

        guard data.selectedTag != 2 else {
            errorPublisher.send("我沒有讀到文字哦，請上傳有文字的圖片")
            loadingStatePublisher.send(false)
            return
        }

        let finalPrompt = data.selectedTag == 1 ? data.prompt?.trimmingCharacters(in: .whitespacesAndNewlines) : data.recognizedText
        guard let prompt = finalPrompt, !prompt.isEmpty else {
            errorPublisher.send("我沒有讀到文字哦")
            loadingStatePublisher.send(false)
            return
        }

        let formattedPrompt = formatPrompt(prompt, audience: data.audience, replyStyle: data.replyStyle)
        print("Formatted prompt: \(formattedPrompt)")

        loadingStatePublisher.send(true)

        Task {
            do {
                let existingResponse = try await firestoreService.fetchResponse(for: prompt)

                if let possibleMeanings = existingResponse?["possible_meanings"] as? [String],
                   let responseMethods = existingResponse?["response_methods"] as? [String] {
                    responsePublisher.send((possibleMeanings, responseMethods))
                    loadingStatePublisher.send(false)
                    return
                }

                let response = try await apiService.generateTextResponse(for: formattedPrompt)
                if let data = response.data(using: .utf8),
                   let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let content = json["content"] as? [String: Any],
                   let possibleMeanings = content["possible_meanings"] as? [String],
                   let responseMethods = content["response_methods"] as? [String] {
                    responsePublisher.send((possibleMeanings, responseMethods))
                }

                if let imageData = data.selectedImage?.jpegData(compressionQuality: 0.75) {
                    let imageURL = try await firestoreService.uploadImage(imageData: imageData)
                    try await firestoreService.saveToFirestore(prompt: prompt, response: response, imageURL: imageURL)
                } else {
                    try await firestoreService.saveToFirestore(prompt: prompt, response: response, imageURL: nil)
                }

                loadingStatePublisher.send(false)

            } catch {
                errorPublisher.send("網路異常，請確認連線")
                loadingStatePublisher.send(false)
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
