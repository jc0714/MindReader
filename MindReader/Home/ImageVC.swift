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

    private var textColor: UIColor = .white

    private var colorButtons = [UIButton]()
    var stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()

        imageCollectionView.delegate = self

        setupViews()
        setupConstraints()

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

    private func setupConstraints() {
        imageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        finalImageView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        saveToFireBaseButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // imageCollectionView constraints
            imageCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageCollectionView.heightAnchor.constraint(equalToConstant: 120),

            // finalImageView constraints
            finalImageView.topAnchor.constraint(equalTo: imageCollectionView.bottomAnchor, constant: 40),
            finalImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            finalImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            finalImageView.heightAnchor.constraint(equalToConstant: 300),

            stackView.bottomAnchor.constraint(equalTo: finalImageView.topAnchor, constant: -20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            stackView.heightAnchor.constraint(equalToConstant: 30),

            // saveButton constraints
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),

            // shareButton constraints
            shareButton.leadingAnchor.constraint(equalTo: saveButton.trailingAnchor, constant: 30),
            shareButton.bottomAnchor.constraint(equalTo: saveButton.bottomAnchor),

            // saveToFireBaseButton constraints
            saveToFireBaseButton.leadingAnchor.constraint(equalTo: shareButton.trailingAnchor, constant: 30),
            saveToFireBaseButton.bottomAnchor.constraint(equalTo: saveButton.bottomAnchor)
        ])
    }

    func didSelectImage(named imageName: String) {
        guard let selectedImage = UIImage(named: imageName) else { return }
        generateImage(with: selectedImage)
    }
    private func setupViews() {
        finalImageView.contentMode = .scaleAspectFit
        view.addSubview(imageCollectionView)
        view.addSubview(finalImageView)

        // 設置顏色按鈕
        let colors: [UIColor] = [.white, .black, .red, .orange, .yellow, .blue, .green, .purple]

        for color in colors {
            let button = createColorButton(color: color)
            colorButtons.append(button)
        }

        stackView = UIStackView(arrangedSubviews: colorButtons)
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        saveButton = createButton(title: "存到相簿去！", backgroundColor: .darkGray, action: #selector(saveImageToAlbum))
        shareButton = createButton(title: "分享", backgroundColor: .darkGray, action: #selector(shareImage))
        saveToFireBaseButton = createButton(title: "貼到相片牆", backgroundColor: .darkGray, action: #selector(saveToFireBase))

        view.addSubview(saveButton)
        view.addSubview(shareButton)
        view.addSubview(saveToFireBaseButton)
        view.addSubview(stackView)
    }

    private func createColorButton(color: UIColor) -> UIButton {
        let button = UIButton()
        button.backgroundColor = color
        button.layer.cornerRadius = 15
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.addTarget(self, action: #selector(colorButtonTapped(_:)), for: .touchUpInside)
        return button
    }

    // 改變文字顏色
    @objc private func colorButtonTapped(_ sender: UIButton) {
        textColor = sender.backgroundColor ?? .white
        regenerateImage()
    }

    private func regenerateImage() {
        guard let backgroundImage = finalImageView.image else { return }
        generateImage(with: backgroundImage)
    }

    private func generateImage(with backgroundImage: UIImage) {
        let renderer = UIGraphicsImageRenderer(size: backgroundImage.size)
        let generatedImage = renderer.image { _ in
            backgroundImage.draw(at: .zero)

            let fontSize = 120
            let text = copiedText ?? ""
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: CGFloat(fontSize)),
                .foregroundColor: textColor
            ]
            let textRect = CGRect(x: 30, y: 60, width: backgroundImage.size.width - 40, height: backgroundImage.size.height - 40)
            text.draw(in: textRect, withAttributes: textAttributes)
        }
        finalImageView.image = generatedImage
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
                try await firestoreService.saveToMorningImageToDatabase(imageURL: imageURL)
                print("Image uploaded successfully, URL: \(imageURL)")
            } catch {
                print("Failed to upload image: \(error)")
            }
        }
    }
}
