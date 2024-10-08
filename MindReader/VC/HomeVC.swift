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

//    let dataToUpload: [[String: Any]] = []

    let dataToUpload: [[String: Any]] = [
        [
            "prompt": "早安，你今天要幹嘛？",
            "possible_meanings": [
                "想知道你今天的安排",
                "可能想約你一起做點什麼",
                "對方想知道你的近況"
            ],
            "response_methods": [
                "我還沒想好耶，你呢？",
                "我打算放鬆一下，你呢？",
                "早安！今天還沒確定要做什麼。"
            ]
        ],
        [
            "prompt": "今天在幹嘛",
            "possible_meanings": [
                "想知道你今天的安排",
                "可能想約你一起做點什麼",
                "對方想知道你的近況"
            ],
            "response_methods": [
                "睡覺看書吃飯，你呢？",
                "在規劃週末的小旅行，你要一起去玩嗎！",
                "我才剛起床，還沒確定要做什麼。"
            ]
        ],
        [
            "prompt": "晚上要一起看電影嗎？",
            "possible_meanings": [
                "想和你一起看電影，可能有點期待。",
                "對方找不到其他人一起看電影。",
                "對方只是隨口問問，想試探你是否會赴約。"
            ],
            "response_methods": [
                "當然好啊，你想看哪一部？",
                "好可惜我今晚有事，你這週還有哪天有空！",
                "我今天不行，之後再看看吧！。"
            ]
        ],
        [
            "prompt": "你喜歡吃日式料理嗎？",
            "possible_meanings": [
                "想約你吃日式料理。",
                "在試探你的飲食習慣，或許為未來的約會做準備。",
                "可能只是隨便聊天，並不一定有特別的意圖。"
            ],
            "response_methods": [
                "我很喜歡，你有推薦的餐廳嗎？",
                "還不錯，但我更喜歡義式料理。",
                "日式料理很讚耶，有什麼推薦的餐廳嗎？"
            ]
        ],
        [
            "prompt": "你今天看起來很累，是不是有心事？",
            "possible_meanings": [
                "關心你的狀態，想知道你是否有什麼煩惱。",
                "覺得你可能需要休息，想提醒你保重自己。",
                "對方想展現心思細膩的一面"
            ],
            "response_methods": [
                "謝謝你的關心，有點累，但沒什麼大問題。",
                "的確最近有點煩心事，謝謝你。",
                "可能是昨晚沒睡好。"
            ]
        ],
        [
            "prompt": "今天要不要一起去散步？",
            "possible_meanings": [
                "想和你一起度過一些時間。",
                "可能想陪你放鬆心情，特意邀你去散步。",
                "想找人一起散散步。"
            ],
            "response_methods": [
                "好啊，我也正好想散散心！",
                "謝謝你的邀請，但我今天有事，改天吧。",
                "好欸，我們去哪裡散步？大稻埕嗎"
            ]
        ]
    ]

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

        Task {
            await firestoreService.batchUploadData(for: dataToUpload)
        }
    }

    // MARK: - Setup Actions

    private func setupActions() {
        homeView.chatButton.addTarget(self, action: #selector(toChatButtonTapped), for: .touchUpInside)
        let chatBarButtonItem = UIBarButtonItem(customView: homeView.chatButton)
        navigationItem.rightBarButtonItem = chatBarButtonItem

        homeView.imageButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        homeView.textButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)

        homeView.submitButton.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)

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
            return
        }

        let audiance = homeView.selectedAudienceText ?? "不限"
        let replyStyle = homeView.selectedReplyStyleText ?? "不限"

        Task {
            do {
                homeView.showLoadingAnimation()

                sender.isUserInteractionEnabled = false
                sender.backgroundColor = .milkYellow

                try await Task.sleep(nanoseconds: 2_000_000_000)

                let existingResponse = try await self.firestoreService.fetchResponse(for: prompt)

                if let possibleMeanings = existingResponse?["possible_meanings"] as? [String],
                   let responseMethods = existingResponse?["response_methods"] as? [String] {
                    self.updateResponseLabels(possibleMeanings: possibleMeanings, responseMethods: responseMethods)

                    sender.isUserInteractionEnabled = true
                    sender.backgroundColor = .pink3

                    homeView.hideLoadingAnimation()

                    return
                }

//                homeView.showLoadingAnimation()

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
        homeView.promptTextField.text = "主管問我有沒有想升職"
    }

    private func configureView(for tag: Int, isImageViewVisible: Bool) {
        homeView.submitButton.tag = tag
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
