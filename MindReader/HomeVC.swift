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
        switch sender.tag {
        case 1:
            guard let prompt = homeView.promptTextField.text, !prompt.isEmpty else {
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
                        print(response)
                        Task {

                            let documentID = UUID().uuidString
                            try await Firestore.firestore().collection("articles").document(documentID).setData([
                                "createdTime": Timestamp(date: Date()),
                                "id": documentID,
                                "userInput": prompt,
                                "reply": response
                            ])
                            print("Document successfully written with ID: \(documentID)")
                        }
                    }
                } catch {
                    print("Failed to get response: \(error)")
                }
            }
        case 0:
            let prompt = recognizedText
            Task {
                do {
                    let response = try await apiService.generateTextResponse(for: prompt)
                    DispatchQueue.main.async {
                        self.homeView.responseLabel.text = response
                        self.view.setNeedsLayout()
                        self.view.layoutIfNeeded()
                        print(response)
                        let uploadRef = Storage.storage().reference(withPath: "memes/\(UUID().uuidString).jpg")
                        guard let imageData = self.homeView.imageView.image?.jpegData(compressionQuality: 0.75) else { return }

                        uploadRef.putData(imageData, metadata: StorageMetadata()) { _, error in
                           guard error == nil else {
                               print("Upload error: \(error!.localizedDescription)")
                               return
                           }
                           uploadRef.downloadURL { url, error in
                               guard let downloadURL = url else {
                                   print("Download URL error: \(error!.localizedDescription)")
                                   return
                               }
                               Task {

                                   let documentID = UUID().uuidString
                                   try await Firestore.firestore().collection("articles").document(documentID).setData([
                                       "createdTime": Timestamp(date: Date()),
                                       "id": documentID,
                                       "imageURL": downloadURL.absoluteString,
                                       "reply": response
                                   ])
                                   print("Document successfully written with ID: \(documentID)")
                               }
                           }
                        }
                    }
                } catch {
                    print("Failed to get response: \(error)")
                }
            }
        default:
            return
        }
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
        homeView.submitButton.tag = 0
        homeView.promptTextField.isHidden = true
        homeView.chooseImageButton.isHidden = false
        homeView.imageView.isHidden = false
        homeView.responseLabel.text = ""
    }

    @objc func enterText() {
        homeView.submitButton.tag = 1
        homeView.imageView.isHidden = true
        homeView.chooseImageButton.isHidden = true
        homeView.promptTextField.isHidden = false
        homeView.responseLabel.text = ""
    }
}
