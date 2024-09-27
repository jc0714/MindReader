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

    func saveUserInfoToFirestore(userIdentifier: String, fullName: String?, email: String?, realUserStatus: Int) {
        let documentID = UUID().uuidString
        let chatRoomId = UUID().uuidString // 固定 chatRoomId

        var userData: [String: Any] = [
            "user": userIdentifier,
            "name": fullName,
            "email": email,
            "realUserStatus": realUserStatus,
            "likePosts": [String](),
            "postIds": [String](),
            "translate": [String](),
            "chatRoomId": chatRoomId // 將 chatRoomId 儲存在 user 資料中
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
        // 新增 msg 集合並存入一筆開場訊息文件
        let chatRef = self.db.collection("Users").document(userId).collection("Chat").document(chatRoomId)
        let messageRef = chatRef.collection("msg")
        let chatData: [String: Any] = [
            "sender": "0",
            "content": "Welcome to the chat!",
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

    func saveToFirestore(prompt: String, response: String, imageURL: String?) async throws {

        let translateRef = db.collection("Translate")

        let documentID = UUID().uuidString
        var data: [String: Any] = [
            "createdTime": Timestamp(date: Date()),
            "id": documentID,
            "reply": response
        ]
        if let imageURL = imageURL {
            data["imageURL"] = imageURL
            data["tag"] = 1
        } else {
            data["userInput"] = prompt
            data["tag"] = 2
        }
        try await translateRef.addDocument(data: data)
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

                let message = Message(content: content, sender: sender, createdTime: timeString)
                messages.append(message)
            }
            completion(messages)
        }
    }

    func setupFirestoreListener(for collection: String, completion: @escaping () -> Void) -> ListenerRegistration? {
        return db.collection(collection).addSnapshotListener { (_, error) in
            if let error = error {
                print("Error listening to documents: \(error)")
            } else {
                completion()
            }
        }
    }
}
