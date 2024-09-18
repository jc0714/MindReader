//
//  HomeVC.swift
//  MindReader
//
//  Created by J oyce on 2024/9/11.

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

        homeView.promptTextField.delegate = self
        homeView.setupLabelGestures(target: self, action: #selector(copyLabelText))

        homeView.generateImageButton.addTarget(self, action: #selector(toGenerateButtonTapped), for: .touchUpInside)
    }

    // MARK: - Submit Action

    @objc private func didTapSubmit(_ sender: UIButton) {
        if sender.tag == 2 {
            showAlert(message: "請上傳有文字的訊息截圖，我來幫你解讀！")
            return
        }

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

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        homeView.promptTextField.resignFirstResponder()
        return true
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
        你是一個善解人意的朋友，用溫柔的語氣回應。
        請根據以下情況回覆，包括「possible_meanings：這句訊息背後意思」和「response_methods：可回覆訊息」兩個部分，各三個。

        \(prompt)

        用繁體中文，以 JSON 格式：
        "content": {
            "possible_meanings": [
                "第一個可能意思",
                "第二個可能意思",
                "第三個可能意思"
            ],
            "response_methods": [
                "第一個回覆",
                "第二個回覆",
                "第三個回覆"
            ]
        }
        """
    }
}
