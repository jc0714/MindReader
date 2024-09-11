//
//  HomeVC.swift
//  MindReader
//
//  Created by J oyce on 2024/9/11.
//

import UIKit
import Vision

class HomeVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    private let homeView = HomeView()
    private let apiService = APIService()

    override func loadView() {
        view = homeView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
                let response = try await apiService.generateTextResponse(for: prompt)
                DispatchQueue.main.async {
                    self.homeView.responseLabel.text = response
                    self.view.setNeedsLayout()
                    self.view.layoutIfNeeded()
                    print(response)
                }
            } catch {
                print("Failed to get response: \(error)")
            }
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
//                    for (keyword, response) in self.responses {
//                        if topCandidate.string.contains(keyword) {
//                            self.textLabel.text = response
//                            break
//                        }
//                    }
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

        homeView.promptTextField.isHidden = true
        homeView.imageView.isHidden = false
    }

    @objc func enterText(_ sender: UIButton) {

        homeView.imageView.isHidden = true
        homeView.promptTextField.isHidden = false
    }
}
