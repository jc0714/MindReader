//
//  BlockManager.swift
//  MindReader
//
//  Created by J oyce on 2024/10/10.
//

import Foundation
import FirebaseFirestore

class BlockManager {

    static let shared = BlockManager() // 使用單例模式讓多個 VC 可以共用

    private init() {}

    func blockUser(authorID: String, authorName: String) {
        addToBlockedList(authorID: authorID, authorName: authorName)
        updateBlockedListInFirebase(userId: authorID)
    }

    func addToBlockedList(authorID: String, authorName: String) {
        var blockedList = UserDefaults.standard.dictionary(forKey: "BlockedList") as? [String: String] ?? [:]

        // 檢查列表中是否已經包含該 authorID
        if blockedList[authorID] == nil {
            blockedList[authorID] = authorName
            UserDefaults.standard.set(blockedList, forKey: "BlockedList")
        }
    }

    func updateBlockedListInFirebase(userId: String) {
        guard let currentUserID = UserDefaults.standard.string(forKey: "userID") else { return }

        let userRef = Firestore.firestore().collection("Users").document(currentUserID)

        userRef.updateData([
            "blockedList": FieldValue.arrayUnion([userId])
        ]) { error in
            if error != nil {
            } else {
                print("封鎖名單已成功更新到 Firebase")
            }
        }
    }
}
