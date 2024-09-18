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

    private var saveButton = UIButton()
    private var shareButton = UIButton()

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

        saveButton = createButton(title: "存到相簿去！", backgroundColor: .darkGray, action: #selector(saveImageToAlbum))
        shareButton = createButton(title: "分享", backgroundColor: .darkGray, action: #selector(shareImage))

        view.addSubview(saveButton)
        view.addSubview(shareButton)
    }

    // MARK: - UI 之後寫在 view
    private func setupConstraints() {
        [photo1, photo2, photo3, finalImageView, saveButton, shareButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            photo1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            photo1.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            photo1.widthAnchor.constraint(equalToConstant: 90),
            photo1.heightAnchor.constraint(equalToConstant: 90),

            photo2.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            photo2.topAnchor.constraint(equalTo: photo1.topAnchor),
            photo2.widthAnchor.constraint(equalToConstant: 90),
            photo2.heightAnchor.constraint(equalToConstant: 90),

            photo3.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            photo3.topAnchor.constraint(equalTo: photo1.topAnchor),
            photo3.widthAnchor.constraint(equalToConstant: 90),
            photo3.heightAnchor.constraint(equalToConstant: 90),

            finalImageView.topAnchor.constraint(equalTo: photo1.bottomAnchor, constant: 40),
            finalImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            finalImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            finalImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            finalImageView.heightAnchor.constraint(equalToConstant: 300),

            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),

            shareButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            shareButton.bottomAnchor.constraint(equalTo: saveButton.bottomAnchor)
        ])
    }

    // MARK: - 存到相簿
    @objc private func saveImageToAlbum() {
        guard let imageToSave = finalImageView.image else { return }
        UIImageWriteToSavedPhotosAlbum(imageToSave, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("儲存失敗: \(error.localizedDescription)")
        } else {
            print("儲存成功")
        }
    }

    // MARK: - 分享圖片
    @objc private func shareImage() {
        guard let imageToShare = finalImageView.image else { return }
        let activityViewController = UIActivityViewController(activityItems: [imageToShare], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }

    // MARK: - Actions
    @objc private func imageTapped(_ sender: UITapGestureRecognizer) {
        guard let selectedImage = (sender.view as? UIImageView)?.image else { return }
        generateImage(with: selectedImage)
    }

    private func generateImage(with backgroundImage: UIImage) {
        let renderer = UIGraphicsImageRenderer(size: backgroundImage.size)
        let generatedImage = renderer.image { _ in
            backgroundImage.draw(at: .zero)

            let text = copiedText ?? ""
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 80),
                .foregroundColor: UIColor.white
            ]
            let textRect = CGRect(x: 20, y: 20, width: backgroundImage.size.width - 40, height: backgroundImage.size.height - 40)
            text.draw(in: textRect, withAttributes: textAttributes)
        }
        finalImageView.image = generatedImage
    }
}
