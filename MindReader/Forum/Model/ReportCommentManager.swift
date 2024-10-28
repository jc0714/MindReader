//
//  ReportCommentManager.swift
//  MindReader
//
//  Created by J oyce on 2024/10/10.
//

import Foundation
import FirebaseFirestore

class ReportCommentManager {

    static let shared = ReportCommentManager() // 使用單例模式讓多個 VC 可以共用

    private init() {} // 禁止外部實例化，強制使用單例

    // MARK: - Public Methods
    func reportComment(commentID: String, reason: String) {
        addToReportedCommentList(commentID: commentID)
        updateReportedCommentListInFirebase(commentID: commentID, reason: reason)
    }

    // MARK: - Private Methods
    func addToReportedCommentList(commentID: String) {
        var reportedList = UserDefaults.standard.stringArray(forKey: "ReportedList") ?? []

        guard !reportedList.contains(commentID) else { return }

        reportedList.append(commentID)
        UserDefaults.standard.set(reportedList, forKey: "ReportedList")
    }

    func updateReportedCommentListInFirebase(commentID: String, reason: String) {
        guard let currentUserID = UserDefaults.standard.string(forKey: "userID") else { return }

        let userRef = Firestore.firestore().collection("Users").document(currentUserID)

        userRef.updateData([
            "reportedCommentList": FieldValue.arrayUnion([commentID])
        ]) { [weak self] error in
            guard error == nil else {
                print("Error updating reported comment list in Firebase: \(String(describing: error))")
                return
            }
            print("檢舉留言已成功更新到 User 的 Firebase")
            self?.saveReportedCommentToCollection(commentID: commentID, reporterID: currentUserID, reason: reason)
        }
    }

    private func saveReportedCommentToCollection(commentID: String, reporterID: String, reason: String) {
        let reportData: [String: Any] = [
            "commentID": commentID,
            "reporter": reporterID,
            "reason": reason,
            "timestamp": Timestamp()
        ]

        Firestore.firestore().collection("ReportedComments").addDocument(data: reportData) { error in
            guard error == nil else {
                print("Error saving reported comment: \(error!)")
                return
            }
            print("檢舉資訊已成功存入 ReportedComments collection")
        }
    }
}
