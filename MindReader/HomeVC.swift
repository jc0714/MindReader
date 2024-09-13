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

    @objc private func didTapSubmit() {
        guard let prompt = homeView.promptTextField.text, !prompt.isEmpty else {
            print("Prompt is empty")
            return
        }

        Task {
            do {
                let randomID = UUID().uuidString
                let uploadRef = Storage.storage().reference(withPath: "memes/\(randomID).jpg")
                guard let imageData = homeView.imageView.image?.jpegData(compressionQuality: 0.75) else { return }

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
                                "imageURL": downloadURL.absoluteString
                            ])
                            print("Document successfully written with ID: \(documentID)")
                        }
                    }
                }
            } catch {
                print("Failed to get response: \(error)")
            }
        }
    }

    // G 老師更簡潔的寫法
//    @objc private func didTapSubmit() {
//        guard let imageData = homeView.imageView.image?.jpegData(compressionQuality: 0.75) else {
//            print("Prompt or image is empty")
//            return
//        }
//
//        Task {
//            do {
//                let uploadRef = Storage.storage().reference(withPath: "memes/\(UUID().uuidString).jpg")
//                let downloadURL = try await uploadRef.putDataAsync(imageData).downloadURL()
//
//                try await Firestore.firestore().collection("articles").document().setData([
//                    "createdTime": Timestamp(date: Date()),
//                    "id": UUID().uuidString,
//                    "imageURL": downloadURL.absoluteString
//                ])
//
//                print("Document successfully written")
//
//            } catch {
//                print("Failed: \(error.localizedDescription)")
//            }
//        }
//    }


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
            recognizeTextInImage(image: image)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func recognizeTextInImage(image: UIImage) {
        guard let cgImage = image.cgImage else { return }

        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                print("文字識別失敗: \(String(describing: error))")
                return
            }

            for observation in observations {
                if let topCandidate = observation.topCandidates(1).first {
                    print("識別到的文字: \(topCandidate.string)")
                }
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
    }

    @objc func showImageView(_ sender: UIButton) {
        tag = 0

        homeView.promptTextField.isHidden = true
        homeView.imageView.isHidden = false
    }

    @objc func enterText(_ sender: UIButton) {
        tag = 1 

        homeView.imageView.isHidden = true
        homeView.promptTextField.isHidden = false
    }
}
