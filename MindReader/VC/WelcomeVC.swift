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
        label.textColor = .brown
        label.textAlignment = .center
        return label
    }()

    private let branchLabel: UILabel = {
        let label = UILabel()
        label.text = "MindReader"
        label.font = UIFont.systemFont(ofSize: 52, weight: .bold)
        label.textColor = .brown
        label.textAlignment = .center
        return label
    }()

    // 使用自定義的 NameInputView
    private let nameInputView = WelcomeView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        addClouds()
    }

    private func setupUI() {

        view.backgroundColor = UIColor(red: 241/255, green: 228/255, blue: 208/255, alpha: 1.0)

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
            nameInputView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50),
            nameInputView.widthAnchor.constraint(equalToConstant: 350),
            nameInputView.heightAnchor.constraint(equalToConstant: 250)
        ])
    }

    private func setupActions() {
        nameInputView.confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
    }

    @objc private func confirmButtonTapped() {
        guard let name = nameInputView.nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
            AlertKitManager.presentErrorAlert(in: self, title: "我沒有讀到文字哦")
            return
        }

        if name.count > 10 {
            AlertKitManager.presentErrorAlert(in: self, title: "名字不要超過十個字哦")
            return
        }
        onNameEntered?(name)
        dismiss(animated: true, completion: nil)
    }

    private func addClouds() {
        let cloudAnimationRange = view.bounds

        // 添加雲朵
        for _ in 0..<10 {
            let randomSize = CGSize(width: CGFloat.random(in: 70...100), height: CGFloat.random(in: 35...50))
            let cloud = createCloudImageView(systemName: "cloud.fill", size: randomSize)
            view.insertSubview(cloud, aboveSubview: welcomeLabel)
            animateCloud(cloud, in: cloudAnimationRange, duration: Double.random(in: 8...15))
        }
    }

    // 創建小雲朵的 UIImageView，使用 SF Symbols
    private func createCloudImageView(systemName: String, size: CGSize) -> UIImageView {
        let cloudImage = UIImage(systemName: systemName)
        let cloudImageView = UIImageView(image: cloudImage)
        cloudImageView.tintColor = UIColor.white
        cloudImageView.alpha = 0.8 // 設置透明度
        cloudImageView.frame.size = size
        cloudImageView.center = randomCloudPosition(in: view.bounds) // 初始位置隨機
        return cloudImageView
    }

    // 隨機生成雲朵的初始位置
    private func randomCloudPosition(in bounds: CGRect) -> CGPoint {
        return CGPoint(
            x: CGFloat.random(in: bounds.minX...bounds.maxX),
            y: CGFloat.random(in: bounds.minY...bounds.maxY)
        )
    }

    // 雲朵自由飄動動畫
    private func animateCloud(_ cloud: UIImageView, in bounds: CGRect, duration: TimeInterval) {
        let randomX = CGFloat.random(in: bounds.minX...bounds.maxX)
        let randomY = CGFloat.random(in: bounds.minY...bounds.maxY)

        UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
            cloud.center = CGPoint(x: randomX, y: randomY)
        }, completion: { _ in
            self.animateCloud(cloud, in: bounds, duration: duration) // 繼續飄動
        })
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

