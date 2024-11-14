//
//  ImageVC.swift
//  MindReader
//
//  Created by J oyce on 2024/9/17.
//

import UIKit

class ImageVC: UIViewController, ImageCollectionViewDelegate {

    private let firestoreService = FirestoreService()
    private let morningImageView = MorningImageView() // 直接初始化 MorningImageView
    var copiedText: String?
    private var textColor: UIColor = .white

    override func loadView() {
        view = morningImageView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        morningImageView.imageCollectionView.delegate = self

        setupActions()
        generateImage(with: UIImage(named: "photo1")!)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    func didSelectImage(named imageName: String) {
        guard let selectedImage = UIImage(named: imageName) else { return }
        generateImage(with: selectedImage)
    }

    private func setupActions() {
        morningImageView.saveButton.addTarget(self, action: #selector(saveImageToAlbum), for: .touchUpInside)
        morningImageView.shareButton.addTarget(self, action: #selector(shareImage), for: .touchUpInside)
        morningImageView.saveToFireBaseButton.addTarget(self, action: #selector(saveToFireBase), for: .touchUpInside)

        morningImageView.colorButtons.forEach { button in
            button.addTarget(self, action: #selector(colorButtonTapped(_:)), for: .touchUpInside)
        }
    }

    @objc private func colorButtonTapped(_ sender: UIButton) {
        HapticFeedbackManager.lightFeedback()
        textColor = sender.backgroundColor ?? .white
        regenerateImage()
    }

    private func regenerateImage() {
        guard let backgroundImage = morningImageView.finalImageView.image else { return }
        generateImage(with: backgroundImage)
    }

    private func generateImage(with backgroundImage: UIImage) {
        let renderer = UIGraphicsImageRenderer(size: backgroundImage.size)
        let generatedImage = renderer.image { _ in
            backgroundImage.draw(at: .zero)
            let text = copiedText ?? ""
            let fontSize: CGFloat = 120
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: fontSize),
                .foregroundColor: textColor
            ]
            let textRect = CGRect(x: 30, y: 60, width: backgroundImage.size.width - 40, height: backgroundImage.size.height - 40)
            text.draw(in: textRect, withAttributes: textAttributes)
        }
        morningImageView.finalImageView.image = generatedImage
    }

    @objc private func saveImageToAlbum() {
        HapticFeedbackManager.successFeedback()
        AlertKitManager.presentSuccessAlert(in: self, title: "儲存成功")

        guard let imageToSave = morningImageView.finalImageView.image else { return }
        UIImageWriteToSavedPhotosAlbum(imageToSave, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("儲存失敗: \(error.localizedDescription)")
        } else {
            print("儲存成功")
        }
    }

    @objc private func shareImage() {
        guard let imageToShare = morningImageView.finalImageView.image else { return }
        let activityViewController = UIActivityViewController(activityItems: [imageToShare], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }

    @objc private func saveToFireBase() {
        HapticFeedbackManager.successFeedback()
        AlertKitManager.presentSuccessAlert(in: self, title: "貼到相片牆！")

        guard let imageData = morningImageView.finalImageView.image?.jpegData(compressionQuality: 0.75) else { return }

        Task {
            do {
                let imageURL = try await firestoreService.uploadMorningImage(imageData: imageData)
                try await firestoreService.saveToMorningImageToDatabase(imageURL: imageURL)
                print("Image uploaded successfully, URL: \(imageURL)")
            } catch {
                print("Failed to upload image: \(error)")
            }
        }
    }
}
