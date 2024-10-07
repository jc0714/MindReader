//
//  ReportIssueVC.swift
//  MindReader
//
//  Created by J oyce on 2024/10/6.
//

import AlertKit
import UIKit
import Firebase

class ReportIssueViewController: UIViewController {

    private let issueLabel: UILabel = {
        let label = UILabel()
        label.text = "請描述您的問題："
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let issueTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.borderWidth = 2
        textView.layer.borderColor = UIColor.pink3.cgColor
        textView.layer.cornerRadius = 10
        textView.backgroundColor = UIColor.systemPink.withAlphaComponent(0.1)
        textView.font = UIFont.systemFont(ofSize: 16)
        return textView
    }()

    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.text = "問題類別："
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let categorySegmentedControl: UISegmentedControl = {
        let items = ["功能異常", "介面問題", "其他建議"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = .pink3.withAlphaComponent(0.2)
        segmentedControl.layer.cornerRadius = 5
        return segmentedControl
    }()

    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("送出", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .pink3.withAlphaComponent(0.7)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }

    private func setupUI() {
        view.addSubview(issueLabel)
        view.addSubview(issueTextView)
        view.addSubview(categoryLabel)
        view.addSubview(categorySegmentedControl)
        view.addSubview(submitButton)

        NSLayoutConstraint.activate([
            categoryLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            categoryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            categoryLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            categorySegmentedControl.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 10),
            categorySegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            categorySegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            categorySegmentedControl.heightAnchor.constraint(equalToConstant: 50),

            issueLabel.topAnchor.constraint(equalTo: categorySegmentedControl.bottomAnchor, constant: 30),
            issueLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            issueLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            issueTextView.topAnchor.constraint(equalTo: issueLabel.bottomAnchor, constant: 10),
            issueTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            issueTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            issueTextView.heightAnchor.constraint(equalToConstant: 150),

            submitButton.topAnchor.constraint(equalTo: issueTextView.bottomAnchor, constant: 30),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            submitButton.widthAnchor.constraint(equalToConstant: 100),
            submitButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc private func submitButtonTapped() {
        guard let issueText = issueTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines), !issueText.isEmpty else {
            AlertKitAPI.present(
                title: "請填入您的問題再送出",
                icon: .error,
                style: .iOS17AppleMusic,
                haptic: .error
            )
            print("Issue text is empty")
            return
        }

        guard let userId = UserDefaults.standard.string(forKey: "userID") else { return }

        let categoryIndex = categorySegmentedControl.selectedSegmentIndex
        let category = categorySegmentedControl.titleForSegment(at: categoryIndex) ?? "其他"

        let data: [String: Any] = [
            "userID": userId,
            "issue": issueText,
            "category": category,
            "timestamp": Timestamp(date: Date())
        ]

        Firestore.firestore().collection("Questions").addDocument(data: data) { error in
            if let error = error {
                print("Error uploading issue: \(error.localizedDescription)")
            } else {
                AlertKitAPI.present(
                    title: "謝謝您的寶貴意見",
                    icon: .heart,
                    style: .iOS17AppleMusic,
                    haptic: .success
                )
                print("Issue successfully uploaded")
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
