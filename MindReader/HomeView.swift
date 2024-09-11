//
//  HomeView.swift
//  MindReader
//
//  Created by J oyce on 2024/9/11.
//

import Foundation
import UIKit

class HomeView: UIView, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let imageButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Image", for: .normal)
        button.backgroundColor = .systemMint
        button.layer.cornerRadius = 10
        return button
    }()

    let textButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Text", for: .normal)
        button.backgroundColor = .systemMint
        button.layer.cornerRadius = 10
        return button
    }()

    let responseLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let chooseImageButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Choose Image", for: .normal)
        button.backgroundColor = .systemMint
        button.layer.cornerRadius = 10
        return button
    }()

    let promptTextField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.cornerRadius = 10
        field.clipsToBounds = true
        field.backgroundColor = .systemGray6
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.secondaryLabel.cgColor
        field.returnKeyType = .done
        field.placeholder = "Please Enter A Prompt"
        field.contentVerticalAlignment = .top
        return field
    }()

    let submitButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Generate", for: .normal)
        button.backgroundColor = .systemMint
        button.layer.cornerRadius = 10
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

        addSubview(imageButton)
        addSubview(textButton)
        addSubview(responseLabel)
        addSubview(imageView)
        addSubview(chooseImageButton)
        addSubview(promptTextField)
        addSubview(submitButton)
        addSubview(indicatorView)

        indicatorView.isHidden = true
        indicatorView.frame = bounds
        indicatorView.backgroundColor = .systemGray6
        indicatorView.alpha = 0.95

        indicatorView.addSubview(activityIndicator)
        activityIndicator.center = center

        NSLayoutConstraint.activate([
            imageButton.topAnchor.constraint(equalTo: topAnchor, constant: 100),
            imageButton.leadingAnchor.constraint(equalTo: centerXAnchor,constant: -120),
            imageButton.widthAnchor.constraint(equalToConstant: 100),
            imageButton.heightAnchor.constraint(equalToConstant: 50),

            textButton.topAnchor.constraint(equalTo: topAnchor, constant: 100),
            textButton.leadingAnchor.constraint(equalTo: centerXAnchor,constant: 20),
            textButton.widthAnchor.constraint(equalToConstant: 100),
            textButton.heightAnchor.constraint(equalToConstant: 50),

            promptTextField.topAnchor.constraint(equalTo: imageButton.bottomAnchor, constant: 30),
            promptTextField.centerXAnchor.constraint(equalTo: centerXAnchor),
            promptTextField.widthAnchor.constraint(equalToConstant: 300),
            promptTextField.heightAnchor.constraint(equalToConstant: 150),

            imageView.topAnchor.constraint(equalTo: imageButton.bottomAnchor, constant: 30),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 300),
            imageView.heightAnchor.constraint(equalToConstant: 150),

            chooseImageButton.topAnchor.constraint(equalTo: imageButton.bottomAnchor, constant: 30),
            chooseImageButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            chooseImageButton.widthAnchor.constraint(equalToConstant: 150),
            chooseImageButton.heightAnchor.constraint(equalToConstant: 50),

            submitButton.topAnchor.constraint(equalTo: promptTextField.bottomAnchor, constant: 20),
            submitButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            submitButton.widthAnchor.constraint(equalToConstant: 300),
            submitButton.heightAnchor.constraint(equalToConstant: 60),

            responseLabel.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 30),
            responseLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            responseLabel.widthAnchor.constraint(equalToConstant: 300),
        ])
        responseLabel.preferredMaxLayoutWidth = 300
    }
}
