//
//  WelcomeVC.swift
//  MindReader
//
//  Created by J oyce on 2024/10/4.
//

import Foundation
import UIKit

class WelcomeVC: UIViewController {
    var onNameEntered: ((String) -> Void)?

    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "歡迎來到"
        label.font = UIFont.systemFont(ofSize: 52, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    private let branchLabel: UILabel = {
        let label = UILabel()
        label.text = "MindReader"
        label.font = UIFont.systemFont(ofSize: 52, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    // 使用自定義的 NameInputView
    private let nameInputView = WelcomeView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }

    private func setupUI() {

//        view.backgroundColor = UIColor(red: 135/255, green: 206/255, blue: 250/255, alpha: 1)
        view.backgroundColor = .milkYellow

        // Add welcomeLabel and titleLabel to the view
        view.addSubview(welcomeLabel)
        view.addSubview(branchLabel)
        view.addSubview(nameInputView)

        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        branchLabel.translatesAutoresizingMaskIntoConstraints = false
        nameInputView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            branchLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 20),
            branchLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            nameInputView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameInputView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            nameInputView.widthAnchor.constraint(equalToConstant: 350),
            nameInputView.heightAnchor.constraint(equalToConstant: 250)
        ])
    }

    private func setupActions() {
        nameInputView.confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
    }

    @objc private func confirmButtonTapped() {
        guard let name = nameInputView.nameTextField.text, !name.isEmpty else { return }
        onNameEntered?(name)
        dismiss(animated: true, completion: nil)
    }
}
//
//class WelcomeVC: UIViewController {
//
//
//    private let titleLabel: UILabel = {
//        let label = UILabel()
//        label.text = "請輸入你的名字"
//        label.font = UIFont.systemFont(ofSize: 18)
//        label.textColor = .white
//        label.textAlignment = .center
//        return label
//    }()
//
//    private let containerView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .white
//        view.layer.cornerRadius = 15
//        view.layer.shadowColor = UIColor.black.cgColor
//        view.layer.shadowOpacity = 0.3
//        view.layer.shadowOffset = CGSize(width: 0, height: 5)
//        view.layer.shadowRadius = 10
//        return view
//    }()
//
//    private let nameTextField: UITextField = {
//        let textField = UITextField()
//        textField.placeholder = "你的名字"
//        textField.borderStyle = .none
//        textField.backgroundColor = UIColor(white: 0.95, alpha: 1)
//        textField.layer.cornerRadius = 8
//        textField.setLeftPaddingPoints(10)
//        textField.font = UIFont.systemFont(ofSize: 16)
//        return textField
//    }()
//
//    private let confirmButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("送出", for: .normal)
//        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
//        button.backgroundColor = UIColor.pink3
//        button.setTitleColor(.white, for: .normal)
//        button.layer.cornerRadius = 8
//        button.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
//        return button
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//    }
//
//    private func setupUI() {
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.frame = view.bounds
//        gradientLayer.colors = [UIColor.milkYellow.cgColor, UIColor.pink3.cgColor]
//        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
//        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
//        view.layer.insertSublayer(gradientLayer, at: 0)
//
//        // Add welcomeLabel and titleLabel to the view
//        view.addSubview(welcomeLabel)
//        view.addSubview(titleLabel)
//        view.addSubview(containerView)
//        containerView.addSubview(nameTextField)
//        containerView.addSubview(confirmButton)
//
//        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        containerView.translatesAutoresizingMaskIntoConstraints = false
//        nameTextField.translatesAutoresizingMaskIntoConstraints = false
//        confirmButton.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            welcomeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
//            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//
//            titleLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 20),
//            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//
//            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            containerView.widthAnchor.constraint(equalToConstant: 300),
//            containerView.heightAnchor.constraint(equalToConstant: 200),
//
//            nameTextField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 35),
//            nameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
//            nameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
//            nameTextField.heightAnchor.constraint(equalToConstant: 60),
//
//            confirmButton.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 25),
//            confirmButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
//            confirmButton.widthAnchor.constraint(equalToConstant: 80),
//            confirmButton.heightAnchor.constraint(equalToConstant: 40)
//        ])
//    }
//
//    @objc private func confirmButtonTapped() {
//        guard let name = nameTextField.text, !name.isEmpty else { return }
//        onNameEntered?(name)
//        dismiss(animated: true, completion: nil)
//    }
//}
//

