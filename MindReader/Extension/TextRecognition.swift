//
//  TextRecognition.swift
//  MindReader
//
//  Created by J oyce on 2024/9/14.
//

import Vision
import UIKit

class TextRecognitionService {

    func recognizeTextInImage(image: UIImage, completion: @escaping (String) -> Void) {
        guard let cgImage = image.cgImage else {
            completion("")
            return
        }

        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                print("文字識別失敗: \(String(describing: error))")
                completion("")
                return
            }

            let recognizedText = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "")
            print(recognizedText)
            completion(recognizedText)
        }

        request.recognitionLanguages = ["zh-Hant"]
        request.recognitionLevel = .accurate

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try requestHandler.perform([request])
        } catch {
            print("處理圖片失敗: \(error)")
            completion("")
        }
    }
}
