//
//  ReportPostManager.swift
//  MindReader
//
//  Created by J oyce on 2024/10/10.
//

import Foundation
import FirebaseFirestore

class ReportPostManager {

    static let shared = ReportPostManager()

    private init() {}

    func addToReportedPostList(postID: String) {
        var reportedList = UserSession.shared.reportedList

        if !reportedList.contains(postID) {
            reportedList.append(postID)
            UserSession.shared.reportedList = reportedList
        }
    }

    func updateReportedPostListInFirebase(postID: String, reason: String) {
        guard let currentUserID = UserSession.shared.userID else { return }

        let userRef = Firestore.firestore().collection("Users").document(currentUserID)

        userRef.updateData([
            "reportedPostList": FieldValue.arrayUnion([postID])
        ]) { [weak self] error in
            guard error == nil else {
                print("Error updating reported post list in Firebase: \(String(describing: error))")
                return
            }
            print("檢舉貼文已成功更新到 User 的 Firebase")
            self?.saveReportedPostToCollection(postID: postID, reporterID: currentUserID, reason: reason)
        }
    }

    private func saveReportedPostToCollection(postID: String, reporterID: String, reason: String) {
        let reportData: [String: Any] = [
            "postID": postID,
            "reporter": reporterID,
            "reason": reason,
            "timestamp": Timestamp()
        ]

        Firestore.firestore().collection("ReportedPosts").addDocument(data: reportData) { error in
            guard error == nil else {
                print("Error saving reported post: \(error!)")
                return
            }
            print("檢舉資訊已成功存入 ReportedPosts collection")
        }
    }

    func reportPost(postID: String, reason: String) {
        addToReportedPostList(postID: postID)

        updateReportedPostListInFirebase(postID: postID, reason: reason)
    }
}
