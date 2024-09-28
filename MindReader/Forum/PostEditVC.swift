//
//  PostEditVC.swift
//  MindReader
//
//  Created by J oyce on 2024/9/15.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore

class PostEditVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private var editView: PostEditView!

    private let firestoreService = FirestoreService()

    private let imageNames = ["photo4", "photo5", "photo6", "photo7"]
    var selectedAvatarIndex = 0

    override func loadView() {
        editView = PostEditView()
        view = editView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .color

        editView.avatarImage.image = UIImage(named: imageNames[selectedAvatarIndex])

        editView.publishButton.addTarget(self, action: #selector(click), for: .touchUpInside)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        editView.imageView.addGestureRecognizer(tapGesture)

        let avatarTapGesture = UITapGestureRecognizer(target: self, action: #selector(changeAvatar))
        editView.avatarImage.addGestureRecognizer(avatarTapGesture)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    @objc func click() {
        Task {
            await handleClick()
        }
    }

    func handleClick() async {

        guard let userId = UserDefaults.standard.string(forKey: "userID"), let userName =                 UserDefaults.standard.string(forKey: "userLastName") else {
            print("User ID is nil")
            return
        }

        if let title = editView.titleTextField.text, !title.isEmpty,
           let content = editView.contentTextView.text, !content.isEmpty,
           let category = editView.selectedCategory, !category.isEmpty {

            do {
                editView.publishButton.isUserInteractionEnabled = false
                var imageURL: String?
                if let image = editView.imageView.image?.jpegData(compressionQuality: 0.75) {
                    imageURL = try await firestoreService.uploadImage(imageData: image)
                    print("Image URL: \(imageURL ?? "")")
                }

                let articles = Firestore.firestore().collection("posts")
                let document = articles.document()
                var data: [String: Any] = [
                    "author": [
                        "email": "JJ",
                        "id": userId,
                        "name": userName
                    ],
                    "avatar": selectedAvatarIndex,
                    "title": title,
                    "content": content,
                    "createdTime": Timestamp(date: Date()),
                    "id": document.documentID,
                    "category": category,
                    "like": []
                ]

                if let imageURL = imageURL {
                    data["image"] = imageURL
                }

                try await document.setData(data)

                guard let userId = UserDefaults.standard.string(forKey: "userID") else {
                    print("User ID is nil")
                    return
                }

                let authorCollection = Firestore.firestore().collection("Users").document(userId)
                try await authorCollection.updateData([
                    "postIds": FieldValue.arrayUnion([document.documentID])
                ])

                NotificationCenter.default.post(name: NSNotification.Name("DataUpdated"), object: nil)

                DispatchQueue.main.async { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }
                editView.publishButton.isUserInteractionEnabled = true
            } catch {
                DispatchQueue.main.async { [weak self] in
                    let alert = UIAlertController(title: "錯誤", message: "圖片上傳或儲存過程中發生錯誤", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "確定", style: .default))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                let alert = UIAlertController(title: "資料不足😭", message: "填好以後再按下送出", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OKKKKK", style: .default))
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }

    @objc func imageViewTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            editView.imageView.image = selectedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    @objc func changeAvatar() {
        selectedAvatarIndex = (selectedAvatarIndex + 1) % imageNames.count
        editView.avatarImage.image = UIImage(named: imageNames[selectedAvatarIndex])
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
