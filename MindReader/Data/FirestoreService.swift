//
//  FirestoreService.swift
//  MindReader
//
//  Created by J oyce on 2024/9/14.
//

import FirebaseFirestore
import FirebaseStorage
import Foundation

class FirestoreService {

    private let db = Firestore.firestore()

    // MARK: Login

    func saveUserInfoToFirestore(appleUserIdentifier: String, appleUserFullName: String?, userFullName: String?, email: String?, realUserStatus: Int) {
        let documentID = UUID().uuidString
        let chatRoomId = UUID().uuidString // 固定 chatRoomId

        let userData: [String: Any] = [
            "appleUserIdentifier": appleUserIdentifier,
            "appleUserFullName": appleUserFullName,
            "userFullName": userFullName,
            "email": email,
            "realUserStatus": realUserStatus,
            "likePosts": [String](),
            "postIds": [String](),
            "translate": [String](),
            "chatRoomId": chatRoomId, // 將 chatRoomId 儲存在 user 資料中
            "createdAt": FieldValue.serverTimestamp(),
            "isDeleted": false
        ]

        // 儲存用戶資料到 Firestore
        db.collection("Users").document(documentID).setData(userData) { error in
            if let error = error {
                print("Error saving user data to Firestore: \(error.localizedDescription)")
            } else {
                print("User data successfully saved to Firestore!")

                UserDefaults.standard.set(documentID, forKey: "userID")
                UserDefaults.standard.set(chatRoomId, forKey: "chatRoomId")
                UserDefaults.standard.synchronize()

                // 其他初始化代碼（如 photos 和 chat 開場訊息）
                self.initializeChatRoom(userId: documentID, chatRoomId: chatRoomId)
            }
        }
    }

    func initializeChatRoom(userId: String, chatRoomId: String) {
        // 新增 msg collection 並存入一筆開場訊息文件
        let chatRef = self.db.collection("Users").document(userId).collection("Chat").document(chatRoomId)
        let messageRef = chatRef.collection("msg")
        let chatData: [String: Any] = [
            "sender": "1",
            "content": "早安午安晚安！☀️✨ 我是阿雲～ 歡迎跟我分享你的日常，快樂或低谷都可以。一起度過每一天吧🌼",
            "createdTime": FieldValue.serverTimestamp()
        ]
        messageRef.addDocument(data: chatData) { chatError in
            if let chatError = chatError {
                print("Error creating chat message document: \(chatError.localizedDescription)")
            } else {
                print("Chat message document created successfully!")
            }
        }
    }

    // MARK: HomeVC

    // 批次打翻譯紀錄進去
    func batchUploadData(for dataToUpload: [[String: Any]]) async {
        let batch = db.batch()

        for data in dataToUpload {
            let documentRef = db.collection("TranslateDB").document() // 這裡自動生成新的 document ID
            batch.setData(data, forDocument: documentRef)
        }

        do {
            try await batch.commit()
            print("Batch upload successful!")
        } catch {
            print("Batch upload failed: \(error.localizedDescription)")
        }
    }

    func fetchResponse(for prompt: String) async throws -> [String: Any]? {
        let querySnapshot = try await db.collection("TranslateDB").whereField("prompt", isEqualTo: prompt).getDocuments()

        if let document = querySnapshot.documents.first {
            print(document.data())
            return document.data()
        } else {
            return nil
        }
    }

    func saveToFirestore(prompt: String, response: String, imageURL: String?) async throws {

        guard let userId = UserDefaults.standard.string(forKey: "userID") else {
            print("User ID is nil")
            return
        }
        
        let translateRef = db.collection("Translate")

        var data: [String: Any] = [
            "createdTime": Timestamp(date: Date()),
            "reply": response
        ]
        if let imageURL = imageURL {
            data["imageURL"] = imageURL
            data["tag"] = 1
        } else {
            data["userInput"] = prompt
            data["tag"] = 2
        }

        let newDocumentRef = try await translateRef.addDocument(data: data)
        let documentID = newDocumentRef.documentID

        let authorCollection = db.collection("Users").document(userId)
        try await authorCollection.updateData([
            "translate": FieldValue.arrayUnion([documentID])
        ])
    }

    func uploadImage(imageData: Data) async throws -> String {

        guard let userId = UserDefaults.standard.string(forKey: "userID") else {
            print("User ID is nil")
            return ""
        }

        let uploadRef = Storage.storage().reference(withPath: "images/\(userId)/\(UUID().uuidString).jpg")
        _ = try await uploadRef.putDataAsync(imageData, metadata: StorageMetadata())
        let downloadURL = try await uploadRef.downloadURL()
        return downloadURL.absoluteString
    }

    // MARK: 早安圖
    func uploadMorningImage(imageData: Data) async throws -> String {

        guard let userId = UserDefaults.standard.string(forKey: "userID") else {
            print("User ID is nil")
            return ""
        }

        let uploadRef = Storage.storage().reference(withPath: "MorningImages/\(userId)/\(UUID().uuidString).jpg")
        _ = try await uploadRef.putDataAsync(imageData, metadata: StorageMetadata())
        let downloadURL = try await uploadRef.downloadURL()
        return downloadURL.absoluteString
    }

    func saveToMorningImageToDatabase(imageURL: String) async throws {

        guard let userId = UserDefaults.standard.string(forKey: "userID") else {
            print("User ID is nil")
            return
        }

        let translateRef = db.collection("Users") .document(userId).collection("MorningImage")

        let data: [String: Any] = [
            "createdTime": Timestamp(date: Date()),
            "imageURL": imageURL
        ]
        try await translateRef.addDocument(data: data)
    }

    func saveMessage(message: String, sender: String, completion: @escaping (Error?) -> Void) {

        guard let userId = UserDefaults.standard.string(forKey: "userID"), let chatId = UserDefaults.standard.string(forKey: "chatRoomId") else {
            print("User ID is nil")
            return
        }

        let messageRef = db.collection("Users") .document(userId).collection("Chat").document(chatId).collection("msg")

        let data: [String: Any] = [
            "content": message,
            "sender": sender,
            "createdTime": FieldValue.serverTimestamp()
        ]

        messageRef.addDocument(data: data) { error in
            completion(error)
        }
    }

    func listenForMessages(completion: @escaping ([Message]) -> Void) {

        guard let userId = UserDefaults.standard.string(forKey: "userID"), let chatId = UserDefaults.standard.string(forKey: "chatRoomId") else {
            print("User ID is nil")
            return
        }

        let messageRef = db.collection("Users") .document(userId).collection("Chat").document(chatId).collection("msg").order(by: "createdTime", descending: false)

        messageRef.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for messages: \(error?.localizedDescription ?? "No error description")")
                return
            }

            var messages = [Message]()
            for document in snapshot.documents {
                let data = document.data()
                let content = data["content"] as? String ?? ""
                let sender = data["sender"] as? String ?? ""
                let createdTime = data["createdTime"] as? Timestamp ?? Timestamp(date: Date())

                let date = createdTime.dateValue()
                let timeString = DateFormatter.sharedFormatter.string(from: date)

                let message = Message(content: content, sender: sender, createdTime: timeString, createdDate: date)
                messages.append(message)
            }
            completion(messages)
        }
    }

    // 監聽留言
    func setupFirestoreListener(for postId: String, completion: @escaping ([Comment]) -> Void) -> ListenerRegistration {
        let blockedList = UserDefaults.standard.dictionary(forKey: "BlockedList") as? [String: String] ?? [:]
        let reportedList = UserDefaults.standard.stringArray(forKey: "ReportedList") ?? []

        let commentsRef = db.collection("posts").document(postId).collection("Comments").order(by: "timestamp", descending: true)

        let listener = commentsRef.addSnapshotListener { [weak self] querySnapshot, error in
            guard let self = self, let documents = querySnapshot?.documents, error == nil else {
                print("Error fetching comments: \(String(describing: error))")
                return
            }

            let comments = documents.compactMap { document -> Comment? in
                let data = document.data()
                guard let author = data["author"] as? String,
                      let content = data["content"] as? String,
                      let authorId = data["authorId"] as? String,
                      let timestamp = data["timestamp"] as? Timestamp else {
                    return nil
                }

                if blockedList.keys.contains(authorId) || reportedList.contains(document.documentID) {
                    return nil
                }

                let documentId = document.documentID

                return Comment(id: documentId, author: author, authorId: authorId, content: content, timestamp: timestamp.dateValue())
            }
            completion(comments)

            let commentCount = documents.count
            NotificationCenter.default.post(name: NSNotification.Name("CommentCountUpdated"), object: nil, userInfo: ["postId": postId, "count": commentCount])

        }
        return listener
    }
    // MARK: 刪除帳號
    func deleteAccount() {
        guard let userId = UserDefaults.standard.string(forKey: "userID") else { return }
        let usersCollection = Firestore.firestore().collection("Users")

        usersCollection.document(userId).updateData(["isDeleted": true]) { error in
            if error == nil {
                print("帳號標記為刪除")
                UserDefaults.standard.removeObject(forKey: "userID")
                UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
//                UserDefaults.standard.removeObject(forKey: "userLastName")
            } else {
                print("刪除出錯了啊啊啊: \(error!.localizedDescription)")
            }
        }
    }
}
