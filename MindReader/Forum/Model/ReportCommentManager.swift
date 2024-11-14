//
//  ReportCommentManager.swift
//  MindReader
//
//  Created by J oyce on 2024/10/10.
//

import Foundation
import FirebaseFirestore

class ReportCommentManager {

    static let shared = ReportCommentManager()

    private init() {}

    func reportComment(commentID: String, reason: String) {
        addToReportedCommentList(commentID: commentID)
        updateReportedCommentListInFirebase(commentID: commentID, reason: reason)
    }

    func addToReportedCommentList(commentID: String) {
        var reportedList = UserSession.shared.reportedList

        guard !reportedList.contains(commentID) else { return }

        reportedList.append(commentID)
        UserSession.shared.reportedList = reportedList
    }

    func updateReportedCommentListInFirebase(commentID: String, reason: String) {
        guard let currentUserID = UserSession.shared.userID else { return }

        let userRef = Firestore.firestore().collection("Users").document(currentUserID)

        userRef.updateData([
            "reportedCommentList": FieldValue.arrayUnion([commentID])
        ]) { [weak self] error in
            guard error == nil else {
                print("Error updating reported comment list in Firebase: \(String(describing: error))")
                return
            }
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
        }
    }
}
