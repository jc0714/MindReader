//
//  EditView.swift
//  MindReader
//
//  Created by J oyce on 2024/9/15.
//

import Foundation
import UIKit

class EditView: UIView {

    let titleTextField = UITextField()
    let categoryTextField = UITextField()
    let contentTextView = UITextView()
    let publishButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        let standardMargin = 16
        let margin = CGFloat(standardMargin / 4)

        titleTextField.placeholder = "文章主題"
        categoryTextField.placeholder = "你覺得他是什麼類別？"

        titleTextField.borderStyle = .roundedRect
        categoryTextField.borderStyle = .roundedRect

        publishButton.setTitle("Publish", for: .normal)
        publishButton.backgroundColor = .blue

        contentTextView.font = UIFont.systemFont(ofSize: 18)
        contentTextView.layer.borderColor = UIColor.lightGray.cgColor
        contentTextView.layer.borderWidth = 1.0

        addSubview(titleTextField)
        addSubview(categoryTextField)
        addSubview(contentTextView)
        addSubview(publishButton)

        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        categoryTextField.translatesAutoresizingMaskIntoConstraints = false
        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        publishButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: margin),
            titleTextField.leftAnchor.constraint(equalTo: leftAnchor, constant: margin),
            titleTextField.rightAnchor.constraint(equalTo: rightAnchor, constant: -margin),
            titleTextField.heightAnchor.constraint(equalToConstant: 50)
        ])

        NSLayoutConstraint.activate([
            categoryTextField.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: margin),
            categoryTextField.leftAnchor.constraint(equalTo: leftAnchor, constant: margin),
            categoryTextField.rightAnchor.constraint(equalTo: rightAnchor, constant: -margin),
            categoryTextField.heightAnchor.constraint(equalToConstant: 50)
        ])

        NSLayoutConstraint.activate([
            contentTextView.topAnchor.constraint(equalTo: categoryTextField.bottomAnchor, constant: margin),
            contentTextView.leftAnchor.constraint(equalTo: leftAnchor, constant: margin),
            contentTextView.rightAnchor.constraint(equalTo: rightAnchor, constant: -margin),
            contentTextView.heightAnchor.constraint(equalToConstant: 500)
        ])

        NSLayoutConstraint.activate([
            publishButton.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: margin),
            publishButton.leftAnchor.constraint(equalTo: leftAnchor, constant: margin),
            publishButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -margin),
            publishButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
