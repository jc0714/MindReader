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

    //MARK: HomeVC

    func saveToFirestore(prompt: String, response: String, imageURL: String?) async throws {
        let documentID = UUID().uuidString
        var data: [String: Any] = [
            "createdTime": Timestamp(date: Date()),
            "id": documentID,
            "reply": response,
        ]
        if let imageURL = imageURL {
            data["imageURL"] = imageURL
            data["tag"] = 1
        } else {
            data["userInput"] = prompt
            data["tag"] = 2
        }
        try await Firestore.firestore().collection("articles").document(documentID).setData(data)
        print("Document successfully written with ID: \(documentID)")
    }

    func uploadImage(imageData: Data) async throws -> String {
        let uploadRef = Storage.storage().reference(withPath: "memes/\(UUID().uuidString).jpg")
        let _ = try await uploadRef.putDataAsync(imageData, metadata: StorageMetadata())
        let downloadURL = try await uploadRef.downloadURL()
        return downloadURL.absoluteString
    }

    func saveMessage(chatRoomId: String, message: String, sender: String, completion: @escaping (Error?) -> Void) {
        let collectionRef = db.collection("chatRooms").document(chatRoomId).collection("messages")
        let data: [String: Any] = [
            "content": message,
            "sender": sender,
            "createdTime": FieldValue.serverTimestamp()
        ]

        collectionRef.addDocument(data: data) { error in
            completion(error)
        }
    }

    func listenForMessages(chatRoomId: String, completion: @escaping ([Message]) -> Void) {

        // 最新訊息在最下方

        let collectionRef = db.collection("chatRooms").document(chatRoomId).collection("messages").order(by: "createdTime", descending: false)

        collectionRef.addSnapshotListener { querySnapshot, error in
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
        let db = Firestore.firestore()

        return db.collection(collection).addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Error listening to documents: \(error)")
            } else {
                completion()
            }
        }
    }

//    func printAllArticles() {
//        db.collection("articles").getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting documents: \(err)")
//            } else {
//                for document in querySnapshot!.documents {
//                    print("\(document.data())")
//                }
//            }
//        }
//    }
}
