//
//  ChatVC.swift
//  MindReader
//
//  Created by J oyce on 2024/9/11.
//

import Foundation
import UIKit

class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var tableView: UITableView!
    private var messages: [String] = []
    private let textField = UITextField()
    private let sendButton = UIButton(type: .system)
    private let inputContainer = UIView()

    private let apiService = APIService()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupInputView()
        setupTableView()
    }

    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white

        tableView.register(ChatCell.self, forCellReuseIdentifier: "ChatCell")
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainer.topAnchor)
        ])
    }

    private func setupInputView() {
        inputContainer.backgroundColor = .white
        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputContainer)

        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter message"
        textField.translatesAutoresizingMaskIntoConstraints = false

        sendButton.setImage(UIImage(systemName: "paperplane"), for: .normal)
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false

        inputContainer.addSubview(textField)
        inputContainer.addSubview(sendButton)

        NSLayoutConstraint.activate([
            inputContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            inputContainer.heightAnchor.constraint(equalToConstant: 100),

            textField.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 8),
            textField.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            textField.heightAnchor.constraint(equalToConstant: 60),
            textField.widthAnchor.constraint(equalToConstant: 320),

            sendButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -8),
            sendButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor)
        ])
    }

    @objc private func sendMessage() {
        guard let text = textField.text, !text.isEmpty else { return }
        messages.append(text)
        tableView.reloadData()
        textField.text = ""

        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)

        Task {
            do {
                let response = try await apiService.generateTextResponse(for: text)
                DispatchQueue.main.async {
                    print(response)
                    self.messages.append(response)
                    self.tableView.reloadData()
                    let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
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

        if indexPath.row%2 == 1{
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
}
