//
//  KeyboardHandler.swift
//  MindReader
//
//  Created by J oyce on 2024/10/8.
//
import Foundation
import UIKit

@objc protocol KeyboardHandler: AnyObject {
    func keyboardWillShow(keyboardHeight: CGFloat)
    func keyboardWillHide()
}

extension UIViewController {
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func handleKeyboardWillShow(_ notification: Notification) {
        guard let keyboardHandlerSelf = self as? KeyboardHandler else { return }
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            keyboardHandlerSelf.keyboardWillShow(keyboardHeight: keyboardHeight)
        }
    }

    @objc func handleKeyboardWillHide(_ notification: Notification) {
        guard let keyboardHandlerSelf = self as? KeyboardHandler else { return }
        keyboardHandlerSelf.keyboardWillHide()
    }

    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
