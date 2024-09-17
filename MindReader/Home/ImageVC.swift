//
//  ImageVC.swift
//  MindReader
//
//  Created by J oyce on 2024/9/17.
//

import UIKit

class ImageVC: UIViewController {

    // MARK: - Properties
    private let photo1 = UIImageView(image: UIImage(named: "photo1"))
    private let photo2 = UIImageView(image: UIImage(named: "photo2"))
    private let photo3 = UIImageView(image: UIImage(named: "photo3"))
    private let finalImageView = UIImageView()
    var copiedText: String?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }

    // MARK: - Setup
    private func setupViews() {
        [photo1, photo2, photo3].forEach {
            $0.contentMode = .scaleAspectFit
            $0.isUserInteractionEnabled = true
            $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:))))
            view.addSubview($0)
        }
        finalImageView.contentMode = .scaleAspectFit
        view.addSubview(finalImageView)
    }

    // MARK: - UI 之後寫在 view
    private func setupConstraints() {
        [photo1, photo2, photo3, finalImageView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            photo1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            photo1.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            photo1.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.28),
            photo1.heightAnchor.constraint(equalTo: photo1.widthAnchor),

            photo2.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            photo2.topAnchor.constraint(equalTo: photo1.topAnchor),
            photo2.widthAnchor.constraint(equalTo: photo1.widthAnchor),
            photo2.heightAnchor.constraint(equalTo: photo1.heightAnchor),

            photo3.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            photo3.topAnchor.constraint(equalTo: photo1.topAnchor),
            photo3.widthAnchor.constraint(equalTo: photo1.widthAnchor),
            photo3.heightAnchor.constraint(equalTo: photo1.heightAnchor),

            finalImageView.topAnchor.constraint(equalTo: photo1.bottomAnchor, constant: 40),
            finalImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            finalImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            finalImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            finalImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4)
        ])
    }

    // MARK: - Actions
    @objc private func imageTapped(_ sender: UITapGestureRecognizer) {
        guard let selectedImage = (sender.view as? UIImageView)?.image else { return }
        generateImage(with: selectedImage)
    }

    private func generateImage(with backgroundImage: UIImage) {
        UIGraphicsBeginImageContext(backgroundImage.size)
        backgroundImage.draw(at: .zero)

        let text = copiedText ?? ""
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 80),
            .foregroundColor: UIColor.white
        ]
        let textRect = CGRect(x: 20, y: 20, width: backgroundImage.size.width - 40, height: backgroundImage.size.height - 40)
        text.draw(in: textRect, withAttributes: textAttributes)

        finalImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}
