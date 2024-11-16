//
//  HomeViewLabel.swift
//  MindReader
//
//  Created by J oyce on 2024/11/16.
//

import Foundation
import UIKit

class HomeViewLabel: UILabel {
    init(text: String, fontSize: CGFloat, textColor: UIColor, fontWeight: UIFont.Weight) {
        super.init(frame: .zero)
        self.text = text
        self.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        self.textColor = textColor
        self.translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CardView: UIView {
    init(cornerRadius: CGFloat, backgroundColor: UIColor = .white) {
        super.init(frame: .zero)
        self.layer.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
        self.translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HomeViewButton: UIButton {
    init(title: String, backgroundColor: UIColor, cornerRadius: CGFloat) {
        super.init(frame: .zero)
        self.setTitle(title, for: .normal)
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = cornerRadius
        self.translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
