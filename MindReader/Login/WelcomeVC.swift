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
