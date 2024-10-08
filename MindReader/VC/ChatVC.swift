//
//  ChatVC.swift
//  MindReader
//
//  Created by J oyce on 2024/9/11.
//

import UIKit
import IQKeyboardManagerSwift

class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate {

    private var chatView: ChatView!
    private var messages: [Message] = []
    private let apiService = APIService()
    private let firebaseService = FirestoreService()

    private var inputContainerBottomConstraint: NSLayoutConstraint!

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.isHidden = true
        return label
    }()

    override func loadView() {
        chatView = ChatView()
        view = chatView

        chatView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: chatView.safeAreaLayoutGuide.topAnchor, constant: 10),
            dateLabel.centerXAnchor.constraint(equalTo: chatView.centerXAnchor),
            dateLabel.widthAnchor.constraint(equalToConstant: 100),
            dateLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // 聊天室上方名字條、input container 下方一點點
        view.backgroundColor = .pink1

        setUpNavigation()

        chatView.tableView.delegate = self
        chatView.tableView.dataSource = self

        chatView.tableView.backgroundColor = .milkYellow

        setUpActions()
        listenForMessages()

        setupKeyboardObservers()
    }

    func setUpNavigation() {

        let titleLabel = UILabel()
        titleLabel.text = "阿雲"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        titleLabel.textColor = UIColor.black
        titleLabel.textAlignment = .left

        self.navigationItem.titleView = titleLabel
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
        tabBarController?.tabBar.isHidden = false
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

    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
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

        chatView.textView.delegate = self
    }

    @objc private func sendMessage(_ sender: UIButton) {
        guard var text = chatView.textView.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else { return }
        let senderName = "0"

        chatView.showLoadingAnimation()

        firebaseService.saveMessage(message: text, sender: senderName) { error in
            if let error = error {
                print("Failed to save message: \(error)")
                return
            }

            self.chatView.resetTextView()

            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
            self.chatView.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            sender.isUserInteractionEnabled = true
        }

        Task {
            do {
                text = formatPrompt(text)
                let response = try await apiService.generateTextResponse(for: text)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        let senderName = "1"

                        self.firebaseService.saveMessage(message: response, sender: senderName) { error in
                            if let error = error {
                                print("Failed to save message: \(error)")
                                return
                            }
                        }
                        print(response)

                        let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                        let numberOfRows = self.chatView.tableView.numberOfRows(inSection: 0)

                        if numberOfRows > 0 {
                            let indexPath = IndexPath(row: numberOfRows - 1, section: 0)
                            self.chatView.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                        }
                        sender.isUserInteractionEnabled = true
                        self.chatView.hideLoadingAnimation()
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

        let isIncoming = message.sender == "1"
        cell.configure(with: message.content, time: message.createdTime, isIncoming: isIncoming)

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
        chatView.textView.resignFirstResponder()
        return true
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let visibleCells = chatView.tableView.visibleCells as? [ChatCell], let firstVisibleCell = visibleCells.first else { return }
        if let indexPath = chatView.tableView.indexPath(for: firstVisibleCell) {
            let messageDate = messages[indexPath.row].createdDate
            let dateString = DateFormatter.formatChatDate(messageDate)

            dateLabel.text = dateString
            dateLabel.isHidden = false
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        dateLabel.isHidden = true
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            dateLabel.isHidden = true
        }
    }

    private func formatPrompt(_ prompt: String) -> String {
        """
        你是善解人意又帶點幽默的朋友。
        請回覆訊息：
        「\(prompt)」
        """
    }
}
