//
//  FirestoreService.swift
//  MindReader
//
//  Created by J oyce on 2024/9/14.
//

import FirebaseFirestore
import FirebaseStorage

class FirestoreService {

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
}
