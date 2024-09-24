//
//  RecoedView.swift
//  MindReader
//
//  Created by J oyce on 2024/9/20.
//

import Foundation
import UIKit

class RecordView: UIView {

//    weak var dataSource: SelectionDataSource?
//    weak var delegate: SelectionViewDelegate?

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
        moveIndicator(to: selectedButton)
    }

    func setData() {
        let titles = ["相片牆", "我的POSTs"]

        for (index, title) in titles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
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

    private func moveIndicator(to button: UIButton?) {
        guard let button = button else { return }
        let indicatorWidth: CGFloat = 120
        let indicatorX = button.frame.origin.x + (button.frame.width - indicatorWidth) / 2

        UIView.animate(withDuration: 0.3) {
            self.indicatorView.frame = CGRect(x: indicatorX, y: self.bounds.height - 2, width: indicatorWidth, height: 2)
        }
    }
}
