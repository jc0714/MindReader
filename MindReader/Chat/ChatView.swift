//
//  ChatView.swift
//  MindReader
//
//  Created by J oyce on 2024/9/14.
//

import Foundation
import UIKit

class ChatView: UIView, UITextViewDelegate {

    let tableView = UITableView(frame: .zero, style: .plain)
    let textView = UITextView()
    let sendButton = UIButton(type: .system)
    let inputContainer = UIView()

    var inputContainerBottomConstraint: NSLayoutConstraint!
    var textViewHeightConstraint: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
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
        tableView.backgroundColor = .clear
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
        inputContainer.backgroundColor = .color
        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(inputContainer)

        textView.isScrollEnabled = false
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 16
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false

        sendButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        sendButton.tintColor = .systemBlue
        sendButton.translatesAutoresizingMaskIntoConstraints = false

        inputContainer.addSubview(textView)
        inputContainer.addSubview(sendButton)

        inputContainerBottomConstraint = inputContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        inputContainerBottomConstraint.isActive = true

        NSLayoutConstraint.activate([
            inputContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            inputContainer.trailingAnchor.constraint(equalTo: trailingAnchor),

            // Send Button Constraints
            sendButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -8),
            sendButton.bottomAnchor.constraint(equalTo: inputContainer.bottomAnchor, constant: -8),
            sendButton.widthAnchor.constraint(equalToConstant: 40),
            sendButton.heightAnchor.constraint(equalToConstant: 40),

            // TextView Constraints
            textView.topAnchor.constraint(equalTo: inputContainer.topAnchor, constant: 8),
            textView.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 8),
            textView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            textView.bottomAnchor.constraint(equalTo: inputContainer.bottomAnchor, constant: -8)
        ])
        textViewHeightConstraint = textView.heightAnchor.constraint(equalToConstant: 36)
        textViewHeightConstraint.isActive = true

        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidChange), name: UITextView.textDidChangeNotification, object: textView)
    }

    func updateInputContainerBottomConstraint(by constant: CGFloat) {
        inputContainerBottomConstraint.constant = constant
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }

    @objc private func textViewDidChange() {
        let contentHeight = textView.sizeThatFits(CGSize(width: textView.frame.width, height: .greatestFiniteMagnitude)).height

        if contentHeight > 150 {
            textViewHeightConstraint.constant = 150
            textView.isScrollEnabled = true
        } else {
            textViewHeightConstraint.constant = contentHeight
            textView.isScrollEnabled = false
        }
        layoutIfNeeded()
    }

    func resetTextView() {
        textView.text = ""
        textViewHeightConstraint.constant = 36
        textView.isScrollEnabled = false
        layoutIfNeeded()
    }
}
