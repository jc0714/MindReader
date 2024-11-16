//
//  GradientView.swift
//  MindReader
//
//  Created by J oyce on 2024/11/16.
//

import Foundation
import UIKit

class GradientView: UIView {

    private let gradient = CAGradientLayer()

    init(startColor: UIColor, endColor: UIColor) {
        super.init(frame: .zero)
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.frame = bounds
        layer.addSublayer(gradient)
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }
}
