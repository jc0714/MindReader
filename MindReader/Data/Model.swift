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
    var avatar: Int
    var title: String
    var createdTime: String
    var id: String
    var category: String
    var content: String
    var image: String?
    var author: Author
    var like: Int
    var comment: Int
}

struct Author {
    var email: String
    var id: String
    var name: String
}

// MARK: Comment

struct Comment {
    let id: String
    let author: String
    let authorId: String
    let content: String
    let timestamp: Date
}

// MARK: Chat

struct Message {
    let content: String
    let sender: String
    let createdTime: String
    let createdDate: Date
}
