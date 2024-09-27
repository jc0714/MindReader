//
//  UserManager.swift
//  MindReader
//
//  Created by J oyce on 2024/9/26.
//

import Foundation

class UserManager {
    static let shared = UserManager()

    private init() {}

    var userId: String? {
        get {
            return UserDefaults.standard.string(forKey: "userId")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "userId")
        }
    }
//
//    // 登入狀態
//    var isLoggedIn: Bool {
//        get {
//            return UserDefaults.standard.bool(forKey: "isLoggedIn")
//        }
//        set {
//            UserDefaults.standard.set(newValue, forKey: "isLoggedIn")
//        }
//    }

    // 聊天室 ID
    var chatId: String? {
        get {
            return UserDefaults.standard.string(forKey: "chatId")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "chatId")
        }
    }
}
