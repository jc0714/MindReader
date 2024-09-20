//
//  RecoedView.swift
//  MindReader
//
//  Created by J oyce on 2024/9/20.
//

import Foundation
import UIKit

class RecordView: UIView {
//
//    weak var dataSource: SelectionDataSource?
//    weak var delegate: SelectionViewDelegate?

    private var buttons: [UIButton] = []
    private var views: [UIView] = []
    private let indicatorView = UIView()
    private var selectedButton: UIButton?
    private var selectedView: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let buttonWidth = bounds.width / CGFloat(buttons.count)
        let buttonHeight = bounds.height - 2
        for (index, button) in buttons.enumerated() {
            button.frame = CGRect(x: CGFloat(index) * buttonWidth, y: 0, width: buttonWidth, height: buttonHeight)
        }
        moveIndicator(to: selectedButton)
    }

    func setData() {
        for index in 0..<2 {
            let button = UIButton(type: .system)
            button.setTitle("BBBBB", for: .normal)
            button.tag = index
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)

            addSubview(button)
            buttons.append(button)
        }

        indicatorView.backgroundColor = .blue
        addSubview(indicatorView)

        selectedButton = buttons.first

        setNeedsLayout()
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        moveIndicator(to: sender)
    }

    private func moveIndicator(to button: UIButton?) {
        guard let button = button else { return }
        UIView.animate(withDuration: 0.3) {
            self.indicatorView.frame = CGRect(x: button.frame.origin.x, y: self.bounds.height - 2, width: button.frame.width, height: 2)
        }
    }
}
