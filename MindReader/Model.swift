//
//  Model.swift
//  MindReader
//
//  Created by J oyce on 2024/9/15.
//

import Foundation

// MARK: Home

struct ChatCompletionResponse: Decodable {
    let choices: [ChatChoice]
}

struct ChatChoice: Decodable {
    let message: MessageContent
}

struct MessageContent: Decodable {
    let content: String
}

enum APIError: Error {
    case invalidURL
    case invalidResponseData
}

// MARK: Forum

struct Post {
    var title: String
    var createdTime: TimeInterval
    var id: String
    var category: String
    var content: String
    var author: Author
}

struct Author {
    var email: String
    var id: String
    var name: String
}

// MARK: Chat

struct Message {
    let content: String
    let sender: String
    let createdTime: Date
}


