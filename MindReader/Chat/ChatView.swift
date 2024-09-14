//
//  ChatView.swift
//  MindReader
//
//  Created by J oyce on 2024/9/14.
//

import Foundation
import UIKit

class ChatView: UIView {

    let tableView = UITableView(frame: .zero, style: .plain)
    let textField = UITextField()
    let sendButton = UIButton(type: .system)
    let inputContainer = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupInputView()
        setupTableView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.register(ChatCell.self, forCellReuseIdentifier: "ChatCell")
        addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainer.topAnchor)
        ])
    }

    private func setupInputView() {
        inputContainer.backgroundColor = .white
        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(inputContainer)

        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter message"
        textField.translatesAutoresizingMaskIntoConstraints = false

        sendButton.setImage(UIImage(systemName: "paperplane"), for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false

        inputContainer.addSubview(textField)
        inputContainer.addSubview(sendButton)

        NSLayoutConstraint.activate([
            inputContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            inputContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            inputContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),

            textField.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 8),
            textField.topAnchor.constraint(equalTo: inputContainer.topAnchor, constant: 8),
            textField.bottomAnchor.constraint(equalTo: inputContainer.bottomAnchor, constant: -8),
            textField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            textField.widthAnchor.constraint(equalToConstant: 300),

            sendButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -8),
            sendButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor)
        ])
    }
}

