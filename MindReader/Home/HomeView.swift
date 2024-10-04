//
//  HomeView.swift
//  MindReader
//
//  Created by J oyce on 2024/9/11.
//

import Foundation
import UIKit
import Lottie

class HomeView: UIView, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private var waitingAnimationView: LottieAnimationView = {
        // 使用自定義的 LottieConfiguration，指定 renderingEngine 為 .mainThread
        let configuration = LottieConfiguration(renderingEngine: .mainThread)
        let animationView = LottieAnimationView(
            name: "runningDoggy",
            configuration: configuration
        )
        return animationView
    }()


//    private var waitingAnimationView: LottieAnimationView = {
//        let animationView = LottieAnimationView(name: "runningDoggy")
//        animationView.renderingEngine = .automatic
//        return animationView
//    }()

    let chatButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "ellipsis.message"), for: .normal)
        button.tintColor = .pink3
        button.layer.cornerRadius = 10
        return button
    }()

    let imageButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Image", for: .normal)
        button.backgroundColor = .pink1
        button.layer.cornerRadius = 10
        return button
    }()

    let textButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Text", for: .normal)
        button.backgroundColor = .pink1
        button.layer.cornerRadius = 10
        return button
    }()

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .pink1
        imageView.layer.cornerRadius = 10
        imageView.image = UIImage(named: "uploadImage")
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let promptTextField: UITextView = {
        let field = UITextView()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.cornerRadius = 10
        field.clipsToBounds = true
        field.backgroundColor = .milkYellow
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.secondaryLabel.cgColor
        field.returnKeyType = .done
        field.font = UIFont.systemFont(ofSize: 16)
        field.isHidden = true
        return field
    }()

    let submitButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Generate", for: .normal)
        button.backgroundColor = .pink1
        button.layer.cornerRadius = 10
        button.tag = 0 // 初始設定在圖片
        return button
    }()

    let generateImageButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "photo.artframe"), for: .normal)
        button.backgroundColor = .pink1
        button.layer.cornerRadius = 10
        button.isHidden = true
        return button
    }()

    let indicatorView = UIView()
    let activityIndicator = UIActivityIndicatorView(style: .large)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }

    private func configureUI() {
        backgroundColor = .systemBackground

        waitingAnimationView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(waitingAnimationView)

        addSubview(chatButton)
        addSubview(imageButton)
        addSubview(textButton)

        addSubview(promptTextField)

        addSubview(imageView)

        addSubview(submitButton)
        addSubview(indicatorView)

        addSubview(generateImageButton)

        indicatorView.isHidden = true
        indicatorView.frame = bounds
        indicatorView.backgroundColor = .milkYellow
        indicatorView.alpha = 0.95

        indicatorView.addSubview(activityIndicator)
        activityIndicator.center = center

        NSLayoutConstraint.activate([
            chatButton.topAnchor.constraint(equalTo: topAnchor, constant: 120),
            chatButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),

            imageButton.topAnchor.constraint(equalTo: topAnchor, constant: 100),
            imageButton.leadingAnchor.constraint(equalTo: centerXAnchor, constant: -120),
            imageButton.widthAnchor.constraint(equalToConstant: 100),
            imageButton.heightAnchor.constraint(equalToConstant: 30),

            textButton.topAnchor.constraint(equalTo: topAnchor, constant: 100),
            textButton.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 20),
            textButton.widthAnchor.constraint(equalToConstant: 100),
            textButton.heightAnchor.constraint(equalToConstant: 30),

            promptTextField.topAnchor.constraint(equalTo: imageButton.bottomAnchor, constant: 30),
            promptTextField.centerXAnchor.constraint(equalTo: centerXAnchor),
            promptTextField.widthAnchor.constraint(equalToConstant: 300),
            promptTextField.heightAnchor.constraint(equalToConstant: 150),

            imageView.topAnchor.constraint(equalTo: imageButton.bottomAnchor, constant: 30),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 300),
            imageView.heightAnchor.constraint(equalToConstant: 150),

            submitButton.topAnchor.constraint(equalTo: promptTextField.bottomAnchor, constant: 20),
            submitButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            submitButton.widthAnchor.constraint(equalToConstant: 300),
            submitButton.heightAnchor.constraint(equalToConstant: 50),

            generateImageButton.bottomAnchor.constraint(equalTo: chatButton.bottomAnchor),
            generateImageButton.trailingAnchor.constraint(equalTo: chatButton.trailingAnchor, constant: 15),

            waitingAnimationView.centerXAnchor.constraint(equalTo: promptTextField.centerXAnchor, constant: 0),
            waitingAnimationView.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 80),
            waitingAnimationView.widthAnchor.constraint(equalToConstant: 300),
            waitingAnimationView.heightAnchor.constraint(equalToConstant: 300)
        ])
        waitingAnimationView.isHidden = true

        bringSubviewToFront(chatButton)
        bringSubviewToFront(waitingAnimationView)

    }

    func showLoadingAnimation() {
        self.bringSubviewToFront(self.waitingAnimationView)
        waitingAnimationView.isHidden = false
        waitingAnimationView.loopMode = .loop
        self.waitingAnimationView.play()
        self.layoutIfNeeded()
    }

    // 隱藏動畫
    func hideLoadingAnimation() {
        UIView.animate(withDuration: 0.5, animations: {
            self.waitingAnimationView.alpha = 0
        }) { _ in
            self.waitingAnimationView.stop()
            self.waitingAnimationView.isHidden = true
            self.waitingAnimationView.alpha = 1
        }
    }

}
