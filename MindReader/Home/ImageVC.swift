//
//  ImageVC.swift
//  MindReader
//
//  Created by J oyce on 2024/9/17.
//

import UIKit

class ImageVC: UIViewController, ImageCollectionViewDelegate {

    private let firestoreService = FirestoreService()

    private let imageCollectionView = ImageCollectionView()

    private let finalImageView = UIImageView()

    var copiedText: String?

    private var saveButton = UIButton()
    private var shareButton = UIButton()
    private var saveToFireBaseButton = UIButton()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        imageCollectionView.delegate = self

        setupViews()
        setupConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    // MARK: - Setup
    private func setupViews() {
        finalImageView.contentMode = .scaleAspectFit
        view.addSubview(imageCollectionView)
        view.addSubview(finalImageView)

        saveButton = createButton(title: "存到相簿去！", backgroundColor: .darkGray, action: #selector(saveImageToAlbum))
        shareButton = createButton(title: "分享", backgroundColor: .darkGray, action: #selector(shareImage))
        saveToFireBaseButton = createButton(title: "貼到相片牆", backgroundColor: .darkGray, action: #selector(saveToFireBase))

        view.addSubview(saveButton)
        view.addSubview(shareButton)
        view.addSubview(saveToFireBaseButton)
    }

    // MARK: - UI 之後寫在 view
    private func setupConstraints() {
        imageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        finalImageView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        saveToFireBaseButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageCollectionView.heightAnchor.constraint(equalToConstant: 120),

            finalImageView.topAnchor.constraint(equalTo: imageCollectionView.bottomAnchor, constant: 40),
            finalImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            finalImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            finalImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            finalImageView.heightAnchor.constraint(equalToConstant: 300),

            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),

            shareButton.leadingAnchor.constraint(equalTo: saveButton.trailingAnchor, constant: 30),
            shareButton.bottomAnchor.constraint(equalTo: saveButton.bottomAnchor),

            saveToFireBaseButton.leadingAnchor.constraint(equalTo: shareButton.trailingAnchor, constant: 30),
            saveToFireBaseButton.bottomAnchor.constraint(equalTo: saveButton.bottomAnchor)
        ])
    }

    func didSelectImage(named imageName: String) {
        guard let selectedImage = UIImage(named: imageName) else { return }
        generateImage(with: selectedImage)
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

    // MARK: - 丟到相片牆
    @objc private func saveToFireBase() {
        guard let imageData = finalImageView.image?.jpegData(compressionQuality: 0.75) else { return }

        Task {
            do {
                let imageURL = try await firestoreService.uploadMorningImage(imageData: imageData)
                print("Image uploaded successfully, URL: \(imageURL)")
            } catch {
                print("Failed to upload image: \(error)")
            }
        }
    }

    private func generateImage(with backgroundImage: UIImage) {
        let renderer = UIGraphicsImageRenderer(size: backgroundImage.size)
        let generatedImage = renderer.image { _ in
            backgroundImage.draw(at: .zero)

            let fontSize = backgroundImage.size.height / 10
            let text = copiedText ?? ""
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: fontSize),
                .foregroundColor: UIColor.white
            ]
            let textRect = CGRect(x: 30, y: 30, width: backgroundImage.size.width - 40, height: backgroundImage.size.height - 40)
            text.draw(in: textRect, withAttributes: textAttributes)
        }
        finalImageView.image = generatedImage
    }
}
