//
//  ChatVC.swift
//  MindReader
//
//  Created by J oyce on 2024/9/11.
//

import UIKit

class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    private var chatView: ChatView!
    private var messages: [String] = []
    private let apiService = APIService()
    private let firebaseService = FirestoreService()

    private var inputContainerBottomConstraint: NSLayoutConstraint!

    private let chatRoomId = "your_chat_room_id"

    override func loadView() {
        chatView = ChatView()
        view = chatView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        chatView.tableView.delegate = self
        chatView.tableView.dataSource = self
        setUpActions()
    }

    private func setUpActions() {
        chatView.sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

        chatView.textField.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        inputContainerBottomConstraint = chatView.inputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        inputContainerBottomConstraint.isActive = true
    }

    @objc private func sendMessage(_ sender: UIButton) {
        guard let text = chatView.textField.text, !text.isEmpty else { return }
        let senderName = "0"

        firebaseService.saveMessage(chatRoomId: chatRoomId, message: text, sender: senderName) { error in
            if let error = error {
                print("Failed to save message: \(error)")
                return
            }

            self.messages.append(text)
            self.chatView.tableView.reloadData()
            self.chatView.textField.text = ""

            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
            self.chatView.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            sender.isUserInteractionEnabled = true
        }
//
//        sender.isUserInteractionEnabled = false
//        messages.append(text)
//        chatView.tableView.reloadData()
//        chatView.textField.text = ""
//
//        let indexPath = IndexPath(row: messages.count - 1, section: 0)
//        chatView.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)

        Task {
            do {
                let response = try await apiService.generateTextResponse(for: text)
                DispatchQueue.main.async {

                    let senderName = "1"

                    self.firebaseService.saveMessage(chatRoomId: self.chatRoomId, message: text, sender: senderName) { error in
                        if let error = error {
                            print("Failed to save message: \(error)")
                            return
                        }
                    }

                    print(response)
                    self.messages.append(response)
                    self.chatView.tableView.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatCell
        let message = messages[indexPath.row]

        if indexPath.row % 2 == 1 {
            cell.configure(with: message, isIncoming: true)
        } else {
            cell.configure(with: message, isIncoming: false)
        }
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

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height

            inputContainerBottomConstraint.constant = -keyboardHeight
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        inputContainerBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}
