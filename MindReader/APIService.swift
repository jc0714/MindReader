//
//  APIService.swift
//  MindReader
//
//  Created by J oyce on 2024/9/11.
//

import Foundation
import UIKit

//struct Message: Codable {
//    let role: String
//    let content: String
//}

class APIService {

    private let apiKey = "\(APIKeys.apiKey)"
    private let apiURL = "https://api.openai.com/v1/chat/completions"

    func generateTextResponse(for prompt: String) async throws -> String {
        let urlRequest = try createURLRequest(with: prompt)
        let (data, _) = try await URLSession.shared.data(for: urlRequest)

        if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
            print("Response JSON: \(json)")
        }

        let chatResponse = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
        guard let firstChoice = chatResponse.choices.first else {
            throw APIError.invalidResponseData
        }

        return firstChoice.message.content.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func createURLRequest(with prompt: String) throws -> URLRequest {
        guard let url = URL(string: apiURL) else {
            throw APIError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let jsonBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [["role": "user", "content": prompt]],
            "max_tokens": 250,
            "temperature": 0.7,

        ]

        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: jsonBody)
        return urlRequest
    }

//    // 格式化 prompt 内容
//    
//    func formatPrompt(_ prompt: String) -> String {
//        """
//        請你扮演一個溫柔又帶點幽默的朋友，跟我輕鬆聊聊天。
//        如果有些煩惱，希望你能給點安慰。
//        生活化的聊天，所以句子簡短即可。
//
//        \(prompt)
//        """
////        你是一個善解人意的朋友，用溫柔的語氣回應。
////        請根據以下情況回覆，包括「possible_meanings：這句訊息背後意思」和「response_methods：可回覆訊息」兩個部分，各三個。
////
////        請以 JSON 格式
////        用繁體中文：
////        \(prompt)
////
////        "content": {
////            "possible_meanings": [
////                "第一個可能意思",
////                "第二個可能意思",
////                "第三個可能意思"
////            ],
////            "response_methods": [
////                "第一個回覆",
////                "第二個回覆",
////                "第三個回覆"
////            ]
////        }
////        """
//
//    }
}
