//
//  HomeVC.swift
//  MindReader
//
//  Created by J oyce on 2024/9/11.


//import UIKit
//
//class ImageVC: UIViewController {
//
//    private let firestoreService = FirestoreService()
//    // MARK: - Properties
//    private let photo1 = UIImageView(image: UIImage(named: "photo1"))
//    private let photo2 = UIImageView(image: UIImage(named: "photo2"))
//    private let photo3 = UIImageView(image: UIImage(named: "photo3"))
//    private let finalImageView = UIImageView()
//
//    var copiedText: String?
//
//    private var saveButton = UIButton()
//    private var shareButton = UIButton()
//    private var saveToFireBaseButton = UIButton()
//
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupViews()
//        setupConstraints()
//    }
//
//    // MARK: - Setup
//    private func setupViews() {
//        [photo1, photo2, photo3].forEach {
//            $0.contentMode = .scaleAspectFit
//            $0.isUserInteractionEnabled = true
//            $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:))))
//            view.addSubview($0)
//        }
//        finalImageView.contentMode = .scaleAspectFit
//        view.addSubview(finalImageView)
//
//        saveButton = createButton(title: "存到相簿去！", backgroundColor: .darkGray, action: #selector(saveImageToAlbum))
//        shareButton = createButton(title: "分享", backgroundColor: .darkGray, action: #selector(shareImage))
//        saveToFireBaseButton = createButton(title: "貼到相片牆", backgroundColor: .darkGray, action: #selector(saveToFireBase))
//
//        view.addSubview(saveButton)
//        view.addSubview(shareButton)
//        view.addSubview(saveToFireBaseButton)
//    }
//
//    // MARK: - UI 之後寫在 view
//    private func setupConstraints() {
//        [photo1, photo2, photo3, finalImageView, saveButton, shareButton, saveToFireBaseButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
//
//        NSLayoutConstraint.activate([
//            photo1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            photo1.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//            photo1.widthAnchor.constraint(equalToConstant: 90),
//            photo1.heightAnchor.constraint(equalToConstant: 90),
//
//            photo2.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            photo2.topAnchor.constraint(equalTo: photo1.topAnchor),
//            photo2.widthAnchor.constraint(equalToConstant: 90),
//            photo2.heightAnchor.constraint(equalToConstant: 90),
//
//            photo3.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            photo3.topAnchor.constraint(equalTo: photo1.topAnchor),
//            photo3.widthAnchor.constraint(equalToConstant: 90),
//            photo3.heightAnchor.constraint(equalToConstant: 90),
//
//            finalImageView.topAnchor.constraint(equalTo: photo1.bottomAnchor, constant: 40),
//            finalImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            finalImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            finalImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
//            finalImageView.heightAnchor.constraint(equalToConstant: 300),
//
//            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
//
//            shareButton.leadingAnchor.constraint(equalTo: saveButton.trailingAnchor, constant: 30),
//            shareButton.bottomAnchor.constraint(equalTo: saveButton.bottomAnchor),
//
//            saveToFireBaseButton.leadingAnchor.constraint(equalTo: shareButton.trailingAnchor, constant: 30),
//            saveToFireBaseButton.bottomAnchor.constraint(equalTo: saveButton.bottomAnchor)
//        ])
//    }
//
//    // MARK: - 存到相簿
//    @objc private func saveImageToAlbum() {
//        guard let imageToSave = finalImageView.image else { return }
//        UIImageWriteToSavedPhotosAlbum(imageToSave, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
//    }
//
//    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
//        if let error = error {
//            print("儲存失敗: \(error.localizedDescription)")
//        } else {
//            print("儲存成功")
//        }
//    }
//
//    // MARK: - 分享圖片
//    @objc private func shareImage() {
//        guard let imageToShare = finalImageView.image else { return }
//        let activityViewController = UIActivityViewController(activityItems: [imageToShare], applicationActivities: nil)
//        present(activityViewController, animated: true, completion: nil)
//    }
//
//    // MARK: - 丟到相片牆
//    @objc private func saveToFireBase() {
//        guard let imageData = finalImageView.image?.jpegData(compressionQuality: 0.75) else { return }
//
//        Task {
//            do {
//                let imageURL = try await firestoreService.uploadMorningImage(imageData: imageData)
//                print("Image uploaded successfully, URL: \(imageURL)")
//            } catch {
//                print("Failed to upload image: \(error)")
//            }
//        }
//    }
//
//    // MARK: - Actions
//    @objc private func imageTapped(_ sender: UITapGestureRecognizer) {
//        guard let selectedImage = (sender.view as? UIImageView)?.image else { return }
//        generateImage(with: selectedImage)
//    }
//
//    private func generateImage(with backgroundImage: UIImage) {
//        let renderer = UIGraphicsImageRenderer(size: backgroundImage.size)
//        let generatedImage = renderer.image { _ in
//            backgroundImage.draw(at: .zero)
//
//            let text = copiedText ?? ""
//            let textAttributes: [NSAttributedString.Key: Any] = [
//                .font: UIFont.systemFont(ofSize: 80),
//                .foregroundColor: UIColor.white
//            ]
//            let textRect = CGRect(x: 20, y: 20, width: backgroundImage.size.width - 40, height: backgroundImage.size.height - 40)
//            text.draw(in: textRect, withAttributes: textAttributes)
//        }
//        finalImageView.image = generatedImage
//    }
//}

import UIKit
import Vision
import Firebase
import FirebaseFirestore
import FirebaseStorage

class HomeVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    // MARK: - Properties
    private let homeView = HomeView()
    private let apiService = APIService()
    private let textRecognizeService = TextRecognitionService()
    private let firestoreService = FirestoreService()

    private var tag = 0
    private var recognizedText: String = ""

    private var copiedText: String = ""

    override func loadView() {
        view = homeView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .color
        setupActions()
    }

    // MARK: - Setup Actions

    private func setupActions() {
        homeView.submitButton.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)
        homeView.imageButton.addTarget(self, action: #selector(showImageView), for: .touchUpInside)
        homeView.textButton.addTarget(self, action: #selector(enterText), for: .touchUpInside)
        homeView.chooseImageButton.addTarget(self, action: #selector(selectImageFromAlbum), for: .touchUpInside)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

        homeView.setupLabelGestures(target: self, action: #selector(copyLabelText))

        homeView.generateImageButton.addTarget(self, action: #selector(toGenerateButtonTapped), for: .touchUpInside)
    }

    // MARK: - Submit Action

    @objc private func didTapSubmit(_ sender: UIButton) {

        if sender.tag == 2 {
            showAlert(message: "請上傳有文字的訊息截圖，我來幫你解讀！")
            return
        }

        // 可設置等待回應動畫

//        sender.isUserInteractionEnabled = false
//        sender.backgroundColor = .color

        let prompt = sender.tag == 1 ? homeView.promptTextField.text : recognizedText

        guard var prompt = prompt, !prompt.isEmpty else {
            print("Prompt is empty")
            return
        }

        Task {
            do {
                prompt = formatPrompt(prompt)
                let response = try await apiService.generateTextResponse(for: prompt)

                if let data = response.data(using: .utf8),
                   let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let content = json["content"] as? [String: Any],
                   let possibleMeanings = content["possible_meanings"] as? [String],
                   let responseMethods = content["response_methods"] as? [String] {

                    print("Possible Meanings: \(possibleMeanings)")
                    print("Response Methods: \(responseMethods)")

                    DispatchQueue.main.async {
                        self.homeView.responseLabel.text = "可能含義\n1.\(possibleMeanings[0])\n2.\(possibleMeanings[1])\n3.\(possibleMeanings[2])\n\n推薦回覆"
                        self.homeView.replyLabel1.text = responseMethods[0]
                        self.homeView.replyLabel2.text = responseMethods[1]
                        self.homeView.replyLabel3.text = responseMethods[2]
                        self.view.setNeedsLayout()
                        self.view.layoutIfNeeded()
                    }
                }

                if let imageData = homeView.imageView.image?.jpegData(compressionQuality: 0.75) {
                    let imageURL = try await firestoreService.uploadImage(imageData: imageData)
                    try await firestoreService.saveToFirestore(prompt: prompt, response: response, imageURL: imageURL)
                } else {
                    try await firestoreService.saveToFirestore(prompt: prompt, response: response, imageURL: nil)
                }

                sender.isUserInteractionEnabled = true
                sender.backgroundColor = .pink1

            } catch {
                print("Failed to get response: \(error)")
            }
        }
    }

    // MARK: - Image Picker

    @objc func selectImageFromAlbum(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        configureView(for: 0, isImageViewVisible: true)

        picker.dismiss(animated: true, completion: nil)

        if let image = info[.originalImage] as? UIImage {
            homeView.imageView.image = image
            homeView.submitButton.tag = 0
            textRecognizeService.recognizeTextInImage(image: image) { recognizedText in
                self.recognizedText = recognizedText
                print("Recognized Text: \(recognizedText)")
                if self.recognizedText.isEmpty {
                    self.homeView.submitButton.tag = 2
                }
            }
        }
    }

    // MARK: - View Configuration

    @objc func showImageView() {
        homeView.generateImageButton.isHidden = true
        configureView(for: 0, isImageViewVisible: true)
    }

    @objc func enterText() {
        homeView.generateImageButton.isHidden = true
        configureView(for: 1, isImageViewVisible: false)
    }

    private func configureView(for tag: Int, isImageViewVisible: Bool) {
        homeView.submitButton.tag = tag
        homeView.promptTextField.isHidden = isImageViewVisible
        homeView.imageView.isHidden = !isImageViewVisible
        homeView.chooseImageButton.isHidden = !isImageViewVisible
        homeView.promptTextField.text = nil
        homeView.imageView.image = nil
        homeView.responseLabel.text = ""
        homeView.replyLabel1.text = ""
        homeView.replyLabel2.text = ""
        homeView.replyLabel3.text = ""
        homeView.generateImageButton.isHidden = true
    }

    // MARK: - Keyboard Handling

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Show Alert

    private func showAlert(message: String) {
        let alertController = UIAlertController(title: "沒有讀到文字", message: message, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true, completion: nil)
    }

    // MARK: - Copy Label Text

    @objc func copyLabelText(_ sender: UITapGestureRecognizer) {
        if let label = sender.view as? UILabel {
            UIPasteboard.general.string = label.text
            copiedText = label.text ?? "早安"
            print("Text copied: \(label.text ?? "")")
        }
        homeView.generateImageButton.isHidden = false
    }

    @objc func toGenerateButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toGenerateImage", sender: copiedText)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGenerateImage",
           let destinationVC = segue.destination as? ImageVC,
           let text = sender as? String {
            destinationVC.copiedText = text
        }
    }

    private func formatPrompt(_ prompt: String) -> String {
        """
        你現在是「另一半翻譯機」，盡量要顯得體貼。理解對方的潛在意圖，並提供可以複製去用的回覆訊息。
        用下方訊息內容分析「possible_meanings：訊息背後隱含意義」和「response_methods：推薦回覆訊息」兩個部分，各三個。

        訊息內容：\(prompt)

        用繁體中文，以 JSON 格式：
        "content": {
            "possible_meanings": [
                "",
                "",
                ""
            ],
            "response_methods": [
                "可回覆訊息1",
                "可回覆訊息2",
                "可回覆訊息3"
            ]
        }
        """
    }
}
