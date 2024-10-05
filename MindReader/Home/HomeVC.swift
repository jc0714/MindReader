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
import Lottie
import AlertKit

class HomeVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    let dataToUpload: [[String: Any]] = []

    // MARK: - Properties

    private let homeView = HomeView()
    private var selectedButton: UIButton?

    private let apiService = APIService()
    private let firestoreService = FirestoreService()

    private let textRecognizeService = TextRecognitionService()

    private var tag = 0 // 選擇傳圖片
    private var recognizedText: String = ""

    private var copiedText: String = ""

    override func loadView() {
        view = homeView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .milkYellow

        self.navigationItem.backButtonTitle = ""

        setupActions()

        selectedButton = homeView.imageButton
        homeView.imageButton.backgroundColor = .pink3
        homeView.imageButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)

//        Task {
//            await firestoreService.batchUploadData(for: dataToUpload)
//        }
    }

    // MARK: - Setup Actions

    private func setupActions() {
        homeView.chatButton.addTarget(self, action: #selector(toChatButtonTapped), for: .touchUpInside)
        homeView.imageButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        homeView.textButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)

        homeView.submitButton.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)

//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        view.addGestureRecognizer(tapGesture)

        let tapGestureToAlbum = UITapGestureRecognizer(target: self, action: #selector(selectImageFromAlbum))
        homeView.imageView.addGestureRecognizer(tapGestureToAlbum)

    }

    @objc func toChatButtonTapped(_ sender: UIButton) {
        let chatVC = ChatVC()
        navigationController?.pushViewController(chatVC, animated: true)
    }

    // MARK: - Submit Action

    @objc private func didTapSubmit(_ sender: UIButton) {

        homeView.promptTextField.resignFirstResponder()

        if sender.tag == 2 {
            AlertKitAPI.present(
                title: "我沒有讀到文字哦，請上傳有文字的圖片",
                icon: .error,
                style: .iOS17AppleMusic,
                haptic: .error
            )
            return
        }

        let prompt = sender.tag == 1 ? homeView.promptTextField.text : recognizedText

        guard let prompt = prompt?.trimmingCharacters(in: .whitespacesAndNewlines), !prompt.isEmpty else {
            AlertKitAPI.present(
                title: "我沒有讀到文字哦",
                icon: .error,
                style: .iOS17AppleMusic,
                haptic: .error
            )

            print("Prompt is empty")

            return
        }

        let audiance = homeView.selectedAudienceText ?? "不限"
        let replyStyle = homeView.selectedReplyStyleText ?? "不限"

        Task {
            do {
                sender.isUserInteractionEnabled = false
                sender.backgroundColor = .milkYellow

                let existingResponse = try await self.firestoreService.fetchResponse(for: prompt)

                if let possibleMeanings = existingResponse?["possible_meanings"] as? [String],
                   let responseMethods = existingResponse?["response_methods"] as? [String]{
                    self.updateResponseLabels(possibleMeanings: possibleMeanings, responseMethods: responseMethods)

                    sender.isUserInteractionEnabled = true
                    sender.backgroundColor = .pink3
                    return
                }

                homeView.showLoadingAnimation()

                let formatedPrompt = formatPrompt(prompt, audiance: audiance, replyStyle: replyStyle)
                print("打出去的 prompt: \(formatedPrompt)")
                let response = try await apiService.generateTextResponse(for: formatedPrompt)

                if let data = response.data(using: .utf8),
                   let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let content = json["content"] as? [String: Any],
                   let possibleMeanings = content["possible_meanings"] as? [String],
                   let responseMethods = content["response_methods"] as? [String] {

                    print("Possible Meanings: \(possibleMeanings)")
                    print("Response Methods: \(responseMethods)")

                    self.updateResponseLabels(possibleMeanings: possibleMeanings, responseMethods: responseMethods)

                }

                if let imageData = homeView.imageView.image?.jpegData(compressionQuality: 0.75) {
                    let imageURL = try await firestoreService.uploadImage(imageData: imageData)
                    try await firestoreService.saveToFirestore(prompt: prompt, response: response, imageURL: imageURL)
                } else {
                    try await firestoreService.saveToFirestore(prompt: prompt, response: response, imageURL: nil)
                }
                homeView.hideLoadingAnimation()
                sender.isUserInteractionEnabled = true
                sender.backgroundColor = .pink3

            } catch {
                homeView.hideLoadingAnimation()
                print("Failed to get response: \(error)")
                sender.isUserInteractionEnabled = true
                sender.backgroundColor = .pink3
            }
        }
    }

    private func updateResponseLabels(possibleMeanings: [String], responseMethods: [String]) {
        DispatchQueue.main.async {
            let toastView = ToastView()
            toastView.generateImageButton.addTarget(self, action: #selector(self.toGenerateButtonTapped), for: .touchUpInside)

            toastView.onCopyTap = { [weak self] text in
                self?.handleCopiedText(text)
                toastView.generateImageButton.isHidden = false
            }

            toastView.configure(with: possibleMeanings, responseMethods: responseMethods)

            toastView.showInView(self.view)
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

    @objc private func buttonTapped(_ sender: UIButton) {
        guard sender != selectedButton else { return }

        if let previousButton = selectedButton {
            UIView.animate(withDuration: 0.2) {
                previousButton.transform = .identity
                previousButton.backgroundColor = .pink1
            }
        }

        selectedButton = sender

        UIView.animate(withDuration: 0.2, animations: {
            sender.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            sender.backgroundColor = .pink3
        })

        if sender == homeView.imageButton {
            showImageView()
        } else if sender == homeView.textButton {
            enterText()
        }
    }

    @objc func showImageView() {
        configureView(for: 0, isImageViewVisible: true)
        homeView.imageView.image = UIImage(named: "uploadImage")
    }

    @objc func enterText() {
        configureView(for: 1, isImageViewVisible: false)
    }

    private func configureView(for tag: Int, isImageViewVisible: Bool) {
        homeView.submitButton.tag = tag
        homeView.submitButton.backgroundColor = .pink3
        homeView.promptTextField.isHidden = isImageViewVisible
        homeView.imageView.isHidden = !isImageViewVisible
        homeView.promptTextField.text = nil
        homeView.imageView.image = nil
    }

    // MARK: - Keyboard Handling

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Copy Label Text

    func handleCopiedText(_ text: String) {
        // 展示複製成功的提示
        AlertKitAPI.present(
            title: "複製成功",
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )

        UIPasteboard.general.string = text
        copiedText = text
        print("Text copied: \(text)")
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

    private func formatPrompt(_ prompt: String, audiance: String, replyStyle: String) -> String {
        """
        你是「另一半翻譯機」，請分析這封訊息的意圖，並針對「該對象」提供「特定風格」的回覆訊息。
        用下方訊息內容分析「possible_meanings：訊息背後隱含意義」和「response_methods：推薦回覆訊息」兩個部分，各三個。

        訊息內容：\(prompt)
        對象：\(audiance)
        回覆風格：\(replyStyle)

        用繁體中文，以 JSON 格式：
        "content": {
            "possible_meanings": [
                "",
                "",
                ""
            ],
            "response_methods": [
                "訊息1",
                "訊息2",
                "訊息3"
            ]
        }
        """
    }
}
