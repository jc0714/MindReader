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

class EditVC: UIViewController {

    private var editView: EditView!

    override func loadView() {
        editView = EditView()
        view = editView
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .color
        
        editView.publishButton.addTarget(self, action: #selector(click), for: .touchUpInside)
    }

    @objc func click() {
        if let title = editView.titleTextField.text, !title.isEmpty,
           let content = editView.contentTextView.text, !content.isEmpty,
           let category = editView.categoryTextField.text, !category.isEmpty {

            navigationController?.popViewController(animated: true)

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
                "createdTime": Timestamp(date: Date()),
                "id": document.documentID,
                "category": category
            ]
            document.setData(data)
        } else {
            let alert = UIAlertController(title: "資料不足😭", message: "填好以後再按下送出", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OKKKKK", style: .default))
            present(alert, animated: true, completion: nil)
        }
    }
}
