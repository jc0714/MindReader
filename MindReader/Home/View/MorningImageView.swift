//
//  MorningImageView.swift
//  MindReader
//
//  Created by J oyce on 2024/11/14.
//

import Foundation
import UIKit

class ImageView: UIView {

    let imageCollectionView = ImageCollectionView()
    let finalImageView = UIImageView()
    var saveButton = UIButton.styledButton(title: "存到相簿去！", backgroundColor: .pink3)
    var shareButton = UIButton.styledButton(title: "分享", backgroundColor: .pink3)
    var saveToFireBaseButton = UIButton.styledButton(title: "貼到相片牆", backgroundColor: .pink3)
    let stackView = UIStackView()
    var colorButtons = [UIButton]()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = .milkYellow

        finalImageView.contentMode = .scaleAspectFit
        addSubview(imageCollectionView)
        addSubview(finalImageView)

        let colors: [UIColor] = [.white, .black, .red, .orange, .yellow, .blue, .green, .purple]
        for color in colors {
            let button = createColorButton(color: color)
            colorButtons.append(button)
        }

        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        colorButtons.forEach { stackView.addArrangedSubview($0) }
        addSubview(stackView)

//        saveButton = createButton(title: "存到相簿去！", backgroundColor: .pink3)
//        shareButton = createButton(title: "分享", backgroundColor: .pink3)
//        saveToFireBaseButton = createButton(title: "貼到相片牆", backgroundColor: .pink3)
        addSubview(saveButton)
        addSubview(shareButton)
        addSubview(saveToFireBaseButton)
    }

    private func createColorButton(color: UIColor) -> UIButton {
        let button = UIButton()
        button.backgroundColor = color
        button.layer.cornerRadius = 15
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        return button
    }

    private func setupConstraints() {
        imageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        finalImageView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        saveToFireBaseButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageCollectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            imageCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageCollectionView.heightAnchor.constraint(equalToConstant: 150),

            finalImageView.topAnchor.constraint(equalTo: imageCollectionView.bottomAnchor, constant: 40),
            finalImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            finalImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            finalImageView.heightAnchor.constraint(equalToConstant: 300),

            stackView.topAnchor.constraint(equalTo: finalImageView.bottomAnchor, constant: 30),
            stackView.centerXAnchor.constraint(equalTo: finalImageView.centerXAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 30),

            shareButton.centerXAnchor.constraint(equalTo: finalImageView.centerXAnchor),
            shareButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),

            saveButton.trailingAnchor.constraint(equalTo: shareButton.leadingAnchor, constant: -20),
            saveButton.bottomAnchor.constraint(equalTo: shareButton.bottomAnchor),

            saveToFireBaseButton.leadingAnchor.constraint(equalTo: shareButton.trailingAnchor, constant: 20),
            saveToFireBaseButton.bottomAnchor.constraint(equalTo: shareButton.bottomAnchor)
        ])
    }
}
