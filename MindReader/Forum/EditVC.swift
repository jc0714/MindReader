//
//  EditVC.swift
//  MindReader
//
//  Created by J oyce on 2024/9/15.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore

class EditVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private var editView: EditView!

    private let firestoreService = FirestoreService()

    override func loadView() {
        editView = EditView()
        view = editView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .color

        editView.publishButton.addTarget(self, action: #selector(click), for: .touchUpInside)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        editView.imageView.addGestureRecognizer(tapGesture)
    }

    @objc func click() {
        Task {
            await handleClick()
        }
    }

    func handleClick() async {
        if let title = editView.titleTextField.text, !title.isEmpty,
           let content = editView.contentTextView.text, !content.isEmpty,
           let category = editView.categoryTextField.text, !category.isEmpty,
           let image = editView.imageView.image?.jpegData(compressionQuality: 0.75) {

            do {
                // 使用 weak self 避免 self 被強引用
                let imageURL = try await firestoreService.uploadImage(imageData: image)
                print("Image URL: \(imageURL)")
                
                let articles = Firestore.firestore().collection("posts")
                let document = articles.document()
                let data: [String: Any] = [
                    "author": [
                        "email": "JJ",
                        "id": "JJCC",
                        "name": "JC"
                    ],
                    "title": title,
                    "content": content,
                    "image": imageURL,
                    "createdTime": Timestamp(date: Date()),
                    "id": document.documentID,
                    "category": category
                ]

                try await document.setData(data)

                DispatchQueue.main.async { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }

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
//
//
//    @objc func click() async {
//        if let title = editView.titleTextField.text, !title.isEmpty,
//           let content = editView.contentTextView.text, !content.isEmpty,
//           let category = editView.categoryTextField.text, !category.isEmpty,
//           let image = editView.imageView.image?.jpegData(compressionQuality: 0.75) {
//
//            do {
//                // 1. 先上傳圖片，等待上傳完成
//                let imageURL = try await firestoreService.uploadImage(imageData: image)
//
//                print("Image URL: \(imageURL)") 
//
//                // 2. 構建 Firestore 的文章數據
//                let articles = Firestore.firestore().collection("posts")
//                let document = articles.document()
//                let data: [String: Any] = [
//                    "author": [
//                        "email": "JJ",
//                        "id": "JJCC",
//                        "name": "JC"
//                    ],
//                    "title": title,
//                    "content": content,
//                    "image": imageURL,
//                    "createdTime": Timestamp(date: Date()),
//                    "id": document.documentID,
//                    "category": category
//                ]
//
//                // 3. 將數據存入 Firestore
//                try await document.setData(data)
//
//                // 4. 成功後再返回頁面
//                DispatchQueue.main.async {
//                    self.navigationController?.popViewController(animated: true)
//                }
//
//            } catch {
//                // 錯誤處理，例如圖片上傳失敗或 Firestore 操作失敗
//                let alert = UIAlertController(title: "錯誤", message: "圖片上傳或儲存過程中發生錯誤", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "確定", style: .default))
//                present(alert, animated: true, completion: nil)
//            }
//        } else {
//            // 資料不完整的提醒
//            let alert = UIAlertController(title: "資料不足😭", message: "填好以後再按下送出", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OKKKKK", style: .default))
//            present(alert, animated: true, completion: nil)
//        }
//    }

    @objc func imageViewTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            editView.imageView.image = selectedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
