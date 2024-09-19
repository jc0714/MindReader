//
//  ChatVC.swift
//  MindReader
//
//  Created by J oyce on 2024/9/11.
//

import UIKit
import IQKeyboardManagerSwift

class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    private var chatView: ChatView!
    private var messages: [Message] = []
    private let apiService = APIService()
    private let firebaseService = FirestoreService()

    private var inputContainerBottomConstraint: NSLayoutConstraint!

    override func loadView() {
        chatView = ChatView()
        view = chatView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .color

        chatView.tableView.delegate = self
        chatView.tableView.dataSource = self
        setUpActions()
        listenForMessages()

        setupKeyboardObservers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         IQKeyboardManager.shared.enable = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            chatView.updateInputContainerBottomConstraint(by: -keyboardHeight + view.safeAreaInsets.bottom)
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        chatView.updateInputContainerBottomConstraint(by: 0)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func listenForMessages() {
        firebaseService.listenForMessages { [weak self] newMessages in
            guard let self = self else { return }
            self.messages = newMessages
            self.chatView.tableView.reloadData()

            if !self.messages.isEmpty {
                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                self.chatView.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }

    private func setUpActions() {
        chatView.sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

        chatView.textField.delegate = self
    }

    @objc private func sendMessage(_ sender: UIButton) {
        guard var text = chatView.textField.text, !text.isEmpty else { return }
        let senderName = "0"

        firebaseService.saveMessage(message: text, sender: senderName) { error in
            if let error = error {
                print("Failed to save message: \(error)")
                return
            }

            self.chatView.textField.text = ""

            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
            self.chatView.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            sender.isUserInteractionEnabled = true
        }

        Task {
            do {
                text = formatPrompt(text)
                let response = try await apiService.generateTextResponse(for: text)
                DispatchQueue.main.async {

                    let senderName = "1"

                    self.firebaseService.saveMessage(message: response, sender: senderName) { error in
                        if let error = error {
                            print("Failed to save message: \(error)")
                            return
                        }
                    }

                    print(response)

                    let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                    self.chatView.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    sender.isUserInteractionEnabled = true
                }
            } catch {
                print("Failed to get response: \(error)")
            }
        }
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as? ChatCell else {
            fatalError("Unable to dequeue ChatCell")
        }

        let message = messages[indexPath.row]

        let isIncoming = indexPath.row % 2 == 1
        cell.configure(with: message.content, isIncoming: isIncoming)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        chatView.textField.resignFirstResponder()
        return true
    }

    private func formatPrompt(_ prompt: String) -> String {
        """
        請你扮演一個溫柔又帶點幽默的朋友，跟我輕鬆聊聊天。
        如果有些煩惱，希望你能給點安慰。
        生活化的聊天，所以句子簡短即可。

        \(prompt)
        """
    }
}
