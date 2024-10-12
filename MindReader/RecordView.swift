//
//  RecoedView.swift
//  MindReader
//
//  Created by J oyce on 2024/9/20.
//

import Foundation
import UIKit

class RecordView: UIView {

    var buttons: [UIButton] = []
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
        if indicatorView.frame == .zero {
            moveIndicator(to: selectedButton)
        }
    }

    func setData() {
        let titles = ["相片牆", "我的貼文"]

        for (index, title) in titles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            button.tag = index
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)

            addSubview(button)
            buttons.append(button)
        }

        indicatorView.backgroundColor = .pink3
        addSubview(indicatorView)

        selectedButton = buttons.first

        setNeedsLayout()
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        moveIndicator(to: sender)
    }

    func updateIndicator(forIndex index: Int) {
        guard index >= 0 && index < buttons.count else { return }
        moveIndicator(to: buttons[index])
    }

    func updateIndicatorPosition(withProgress progress: CGFloat) {
        guard buttons.count >= 2 else { return }

        let buttonWidth = bounds.width / CGFloat(buttons.count)
        let indicatorWidth: CGFloat = 120

        // 計算指標的位置
        let startX = buttons[0].frame.origin.x + (buttonWidth - indicatorWidth) / 2
        let indicatorX = startX + (buttonWidth * progress)

        indicatorView.frame = CGRect(x: indicatorX, y: bounds.height - 2, width: indicatorWidth, height: 2)
    }

    private func moveIndicator(to button: UIButton?) {
        guard let button = button else { return }
        let indicatorWidth: CGFloat = 120
        let indicatorX = button.frame.origin.x + (button.frame.width - indicatorWidth) / 2

        UIView.animate(withDuration: 0.3) {
            self.indicatorView.frame = CGRect(x: indicatorX, y: self.bounds.height - 2, width: indicatorWidth, height: 2)
        }
    }
}
