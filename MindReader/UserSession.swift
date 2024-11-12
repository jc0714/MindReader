//
//  UserSession.swift
//  MindReader
//
//  Created by J oyce on 2024/11/12.
//

import Foundation

class UserSession {
    static let shared = UserSession()
    private init() {}

    var userID: String? {
        get {
            return UserDefaults.standard.string(forKey: UserDefaultsKeys.userID)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.userID)
        }
    }

    var chatRoomId: String? {
        get {
            return UserDefaults.standard.string(forKey: UserDefaultsKeys.chatRoomId)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.chatRoomId)
        }
    }

    var userLastName: String? {
        get {
            return UserDefaults.standard.string(forKey: UserDefaultsKeys.userLastName)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.userLastName)
        }
    }

    var isUserLoggedIn: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaultsKeys.isUserLoggedIn)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.isUserLoggedIn)
        }
    }

    var blockedList: [String: String] {
        get { UserDefaults.standard.dictionary(forKey: UserDefaultsKeys.blockedList) as? [String: String] ?? [:] }
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.blockedList) }
    }

    var reportedList: [String] {
        get { UserDefaults.standard.stringArray(forKey: UserDefaultsKeys.reportedList) ?? [] }
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.reportedList) }
    }

    func clearUserID() {
        userID = nil
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.userID)
    }
}

struct UserDefaultsKeys {
    static let userID = "userID"
    static let chatRoomId = "chatRoomId"
    static let userLastName = "userLastName"
    static let isUserLoggedIn = "isUserLoggedIn"

    static let blockedList = "BlockedList"
    static let reportedList = "ReportedList"
}
