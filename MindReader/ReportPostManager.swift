//
//  ReportPostManager.swift
//  MindReader
//
//  Created by J oyce on 2024/10/10.
//

import Foundation
import FirebaseFirestore

class ReportPostManager {

    static let shared = ReportPostManager() // 使用單例模式讓多個 VC 可以共用

    private init() {}

    // 新增到本地檢舉列表
    func addToReportedPostList(postID: String) {
        var reportedList = UserDefaults.standard.stringArray(forKey: "ReportedList") ?? []

        if !reportedList.contains(postID) {
            reportedList.append(postID)
            UserDefaults.standard.set(reportedList, forKey: "ReportedList")
        }
    }

    // 更新 Firebase 中的檢舉列表
    func updateReportedPostListInFirebase(postID: String, reason: String) {
        guard let currentUserID = UserDefaults.standard.string(forKey: "userID") else { return }

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

    // 儲存檢舉資訊到 Firestore 中的 ReportedPosts 集合
    private func saveReportedPostToCollection(postID: String, reporterID: String, reason: String) {
        let reportData: [String: Any] = [
            "postID": postID,
            "reporter": reporterID,
            "reason": reason,
            "timestamp": Timestamp() // 加入檢舉的時間
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
        // 更新本地檢舉列表
        addToReportedPostList(postID: postID)

        // 更新 Firebase 檢舉列表
        updateReportedPostListInFirebase(postID: postID, reason: reason)
    }
}
