//
//  APIService.swift
//  MindReader
//
//  Created by J oyce on 2024/9/11.
//

import Foundation
import UIKit

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
            "temperature": 0.7
        ]

        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: jsonBody)
        return urlRequest
    }
}
