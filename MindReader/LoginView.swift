//
//  LoginView.swift
//  MindReader
//
//  Created by J oyce on 2024/10/14.
//

import Foundation
import UIKit
import Lottie

class MindReaderAnimationView: UIView {

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "loginBackground"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let animationView: LottieAnimationView = {
        let view = LottieAnimationView(name: "msgBubble")
        view.loopMode = .loop
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: self.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])

        // 添加動畫
        addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 10),
            animationView.widthAnchor.constraint(equalToConstant: 300),  // 調整動畫寬度
            animationView.heightAnchor.constraint(equalToConstant: 300)  // 調整動畫高度
        ])

        animationView.play()  // 循環播放動畫
    }
}
