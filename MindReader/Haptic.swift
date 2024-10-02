//
//  Haptic.swift
//  MindReader
//
//  Created by J oyce on 2024/10/2.
//

import UIKit

class HapticFeedbackManager {
    static func successFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

