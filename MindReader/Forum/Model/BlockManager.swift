//
//  BlockManager.swift
//  MindReader
//
//  Created by J oyce on 2024/10/10.
//

import Foundation
import FirebaseFirestore

class BlockManager {

    static let shared = BlockManager()

    private init() {}

    func blockUser(authorID: String, authorName: String) {
        addToBlockedList(authorID: authorID, authorName: authorName)
        updateBlockedListInFirebase(userId: authorID)
    }

    func addToBlockedList(authorID: String, authorName: String) {
        var blockedList = UserSession.shared.blockedList

        if blockedList[authorID] == nil {
            blockedList[authorID] = authorName
            UserSession.shared.blockedList = blockedList
        }
    }

    func updateBlockedListInFirebase(userId: String) {
        guard let currentUserID = UserSession.shared.userID else { return }

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
