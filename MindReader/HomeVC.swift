//
//  HomeVC.swift
//  MindReader
//
//  Created by J oyce on 2024/9/11.
//

import UIKit
import Vision
import Firebase
import FirebaseFirestore
import FirebaseStorage

class HomeVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    private let homeView = HomeView()
    private let apiService = APIService()
    private var tag = 0
    private var recognizedText : String = ""

    override func loadView() {
        view = homeView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .color
        setupActions()
    }

    private func setupActions() {
        homeView.submitButton.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)
        homeView.imageButton.addTarget(self, action: #selector(showImageView), for: .touchUpInside)
        homeView.textButton.addTarget(self, action: #selector(enterText), for: .touchUpInside)
        homeView.chooseImageButton.addTarget(self, action: #selector(selectImageFromAlbum), for: .touchUpInside)
    }

    @objc private func didTapSubmit(_ sender: UIButton) {

        if sender.tag == 3 {
            showAlert(message: "請上傳有文字的訊息截圖，我來幫你解讀！")
            return
        }

        let prompt = sender.tag == 1 ? homeView.promptTextField.text : recognizedText

        guard let prompt = prompt, !prompt.isEmpty else {
            print("Prompt is empty")
            return
        }

        Task {
            do {
                let response = try await apiService.generateTextResponse(for: prompt)
                DispatchQueue.main.async {
                    self.homeView.responseLabel.text = response
                    self.view.setNeedsLayout()
                    self.view.layoutIfNeeded()
                }

                if sender.tag == 0 {
                    await handleImageUpload(response: response)
                } else {
                    try await saveToFirestore(prompt: prompt, response: response, imageURL: nil)
                }
            } catch {
                print("Failed to get response: \(error)")
            }
        }
    }

    private func handleImageUpload(response: String) async {
        guard let imageData = homeView.imageView.image?.jpegData(compressionQuality: 0.75) else { return }

        let uploadRef = Storage.storage().reference(withPath: "memes/\(UUID().uuidString).jpg")

        do {
            let _ = try await uploadRef.putDataAsync(imageData, metadata: StorageMetadata())
            let downloadURL = try await uploadRef.downloadURL()
            try await saveToFirestore(prompt: recognizedText, response: response, imageURL: downloadURL.absoluteString)
        } catch {
            print("Image upload failed: \(error.localizedDescription)")
        }
    }

    private func saveToFirestore(prompt: String, response: String, imageURL: String?) async throws {
        let documentID = UUID().uuidString
        var data: [String: Any] = [
            "createdTime": Timestamp(date: Date()),
            "id": documentID,
            "reply": response,
            "userInput": prompt
        ]
        if let imageURL = imageURL {
            data["imageURL"] = imageURL
        }
        try await Firestore.firestore().collection("articles").document(documentID).setData(data)
        print("Document successfully written with ID: \(documentID)")
    }

    private func showAlert(message: String) {
        let alertController = UIAlertController(title: "沒有讀到文字", message: message, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true, completion: nil)
    }

    @objc func selectImageFromAlbum(_ sender: UIButton) {

        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        picker.dismiss(animated: true, completion: nil)

        if let image = info[.originalImage] as? UIImage {
            homeView.imageView.image = image
            recognizedText = recognizeTextInImage(image: image)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func recognizeTextInImage(image: UIImage) -> String {
        guard let cgImage = image.cgImage else { return "" }

        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                print("文字識別失敗: \(String(describing: error))")
                return
            }

            self.recognizedText = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "")
            print(self.recognizedText)
            if self.recognizedText == ""{
                self.homeView.submitButton.tag = 3
            }
        }

        request.recognitionLanguages = ["zh-Hant"]
        request.recognitionLevel = .accurate

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try requestHandler.perform([request])
        } catch {
            print("處理圖片失敗: \(error)")
        }
        return recognizedText
    }

    @objc func showImageView() {
        configureView(for: 0, isImageViewVisible: true)
    }

    @objc func enterText() {
        configureView(for: 1, isImageViewVisible: false)
    }

    private func configureView(for tag: Int, isImageViewVisible: Bool) {
        homeView.submitButton.tag = tag
        homeView.promptTextField.isHidden = isImageViewVisible
        homeView.imageView.isHidden = !isImageViewVisible
        homeView.chooseImageButton.isHidden = !isImageViewVisible
        homeView.imageView.image = nil
        homeView.responseLabel.text = ""
    }
}
