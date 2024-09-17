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

    private let userId = "9Y2GjnVg8TEoze0GUJSU"
    private let chatId = "7jAWex6b1RUsAwKCswGD"

    // MARK: HomeVC

    func saveToFirestore(prompt: String, response: String, imageURL: String?) async throws {

        let translateRef = db.collection("Users") .document(userId).collection("Translate")

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
        let uploadRef = Storage.storage().reference(withPath: "images/\(UUID().uuidString).jpg")
        let _ = try await uploadRef.putDataAsync(imageData, metadata: StorageMetadata())
        let downloadURL = try await uploadRef.downloadURL()
        return downloadURL.absoluteString
    }

    func saveMessage(message: String, sender: String, completion: @escaping (Error?) -> Void) {

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

                let message = Message(content: content, sender: sender, createdTime: createdTime.dateValue())
                messages.append(message)
            }
            completion(messages)
        }
    }

    func setupFirestoreListener(for collection: String, completion: @escaping () -> Void) -> ListenerRegistration? {
        return db.collection(collection).addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Error listening to documents: \(error)")
            } else {
                completion()
            }
        }
    }
}
