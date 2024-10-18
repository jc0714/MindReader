//
//  HomeVC.swift
//  MindReader
//
//  Created by J oyce on 2024/9/11.

import UIKit
import Vision
import Lottie
import FirebaseCrashlytics

class HomeVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

//    let dataToUpload: [[String: Any]] = []

    // MARK: - Properties

    private let homeView = HomeView()
    private var viewModel: HomeViewModel!

    private var selectedButton: UIButton?

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
        homeView.imageButton.backgroundColor = .pink3.withAlphaComponent(0.8)
        homeView.imageButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)

        viewModel = HomeViewModel(apiService: APIService(), firestoreService: FirestoreService())
        setupViewModelBindings()
        setupActions()
//        Task {
//            await firestoreService.batchUploadData(for: dataToUpload)
//        }
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
        HapticFeedbackManager.lightFeedback()
        let chatVC = ChatVC()
        navigationController?.pushViewController(chatVC, animated: true)
    }

    // MARK: - ViewModel Bindings

    private func setupViewModelBindings() {
        viewModel.onLoadingStateChange = { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.homeView.showLoadingAnimation()
                    self?.homeView.submitButton.isUserInteractionEnabled = false
                    self?.homeView.submitButton.backgroundColor = .milkYellow
                } else {
                    self?.homeView.hideLoadingAnimation()
                    self?.homeView.submitButton.isUserInteractionEnabled = true
                    self?.homeView.submitButton.backgroundColor = .pink3.withAlphaComponent(0.8)
                }
            }
        }

        viewModel.onResponseReceived = { [weak self] possibleMeanings, responseMethods in
            self?.updateResponseLabels(possibleMeanings: possibleMeanings, responseMethods: responseMethods)
        }

        viewModel.onErrorOccurred = { [weak self] errorMessage in
            AlertKitManager.presentErrorAlert(in: self!, title: errorMessage)
        }
    }

    @objc private func didTapSubmit(_ sender: UIButton) {
        HapticFeedbackManager.lightFeedback()
        homeView.promptTextField.resignFirstResponder()

        let prompt = sender.tag == 1 ? homeView.promptTextField.text : recognizedText
        let audience = homeView.selectedAudienceText
        let replyStyle = homeView.selectedReplyStyleText
        let selectedImage = homeView.imageView.image

        let submissionData = TranslateData(
            prompt: prompt,
            recognizedText: recognizedText,
            selectedImage: selectedImage,
            selectedTag: sender.tag,
            audience: audience,
            replyStyle: replyStyle
        )

        viewModel.submit(data: submissionData)
    }

    private func updateResponseLabels(possibleMeanings: [String], responseMethods: [String]) {
        DispatchQueue.main.async {
            let toastView = ToastView()
            toastView.generateImageButton.addTarget(self, action: #selector(self.toGenerateButtonTapped), for: .touchUpInside)

            toastView.onCopyTap = { [weak self] text in
                self?.handleCopiedText(text)
                toastView.generateImageButton.isHidden = false
                toastView.hintLabel.isHidden = true
            }

            toastView.configure(with: possibleMeanings, responseMethods: responseMethods)
            toastView.showInView(self.view) {
                self.homeView.promptTextField.text = nil
                self.homeView.imageView.image = UIImage(named: "uploadImage")
            }
        }
    }

    // MARK: - Image Picker

    @objc func selectImageFromAlbum(_ sender: UIButton) {
        HapticFeedbackManager.lightFeedback()

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
        HapticFeedbackManager.lightFeedback()

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
            sender.backgroundColor = .pink3.withAlphaComponent(0.8)
        })

        if sender == homeView.imageButton {
            showImageView()
        } else if sender == homeView.textButton {
            enterText()
        }
    }

    private func showImageView() {
        configureView(for: 0, isImageViewVisible: true)
        homeView.imageView.image = UIImage(named: "uploadImage")
    }

    private func enterText() {
        configureView(for: 1, isImageViewVisible: false)
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
        AlertKitManager.presentSuccessAlert(in: self, title: "複製成功")
        UIPasteboard.general.string = text
        copiedText = text
        print("Text copied: \(text)")
    }

    @objc func toGenerateButtonTapped(_ sender: UIButton) {
        let textAdjustmentVC = TextAdjustmentVC()
        textAdjustmentVC.copiedText = copiedText
        textAdjustmentVC.modalPresentationStyle = .fullScreen // 設置全螢幕顯示

        textAdjustmentVC.onConfirm = { [weak self] updatedText in
            self?.performSegue(withIdentifier: "toGenerateImage", sender: updatedText)
        }

        present(textAdjustmentVC, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGenerateImage",
           let destinationVC = segue.destination as? ImageVC,
           let text = sender as? String {
            destinationVC.copiedText = text
        }
    }
}
