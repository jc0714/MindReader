//
//  PlaceholderView.swift
//  MindReader
//
//  Created by J oyce on 2024/10/10.
//

import Foundation
import UIKit

class PlaceholderView: UIView {

    // Icon
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .gray
        return imageView
    }()

    // First Label
    private let label1: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        return label
    }()

    // Second Label
    private let label2: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        return label
    }()

    // Custom initializer with symbol and labels
    init(symbol: String, label1Text: String, label2Text: String) {
        super.init(frame: .zero)
        setupUI(symbol: symbol, label1Text: label1Text, label2Text: label2Text)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI(symbol: String, label1Text: String, label2Text: String) {
        // Set the image and labels with the provided values
        iconImageView.image = UIImage(systemName: symbol)
        label1.text = label1Text
        label2.text = label2Text

        // Add views to the stack view
        let stackView = UIStackView(arrangedSubviews: [iconImageView, label1, label2])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center

        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 60),
            iconImageView.heightAnchor.constraint(equalToConstant: 60),

            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }

    func show(in parentView: UIView) {
        parentView.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            self.topAnchor.constraint(equalTo: parentView.topAnchor, constant: 80),
            self.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
        ])
        self.isHidden = false
    }

    func hide() {
        self.isHidden = true
    }
}
