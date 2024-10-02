//
//  Animation.swift
//  MindReader
//
//  Created by J oyce on 2024/10/2.
//

import Foundation
import UIKit
import Lottie

class AnimationUtility {

    static func playHeartAnimation(above view: UIView) {
        guard let superview = view.superview else { return }

        superview.layoutIfNeeded()

        superview.subviews.forEach { subview in
            if subview is LottieAnimationView {
                subview.removeFromSuperview()
            }
        }

        let animationView = LottieAnimationView(name: "heart")
        let animationSize: CGFloat = 150
        let xPosition = view.frame.midX - animationSize / 2
        let yPosition = view.frame.minY - 90

        animationView.frame = CGRect(x: xPosition, y: yPosition, width: animationSize, height: animationSize)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce

        superview.insertSubview(animationView, belowSubview: view)

        // 播放動畫
        animationView.play { (finished) in
            // 動畫結束後移除動畫視圖
            animationView.removeFromSuperview()
        }
    }
}


//class AnimationUtility {

//    static func playHeartAnimation(on view: UIView) {
//        // 移除之前的動畫視圖，防止重複添加
//        view.subviews.forEach { subview in
//            if subview is LottieAnimationView {
//                subview.removeFromSuperview()
//            }
//        }
//
//        // 創建 Lottie 動畫視圖
//        let animationView = LottieAnimationView(name: "heart")
//        animationView.frame = view.bounds
//        animationView.contentMode = .scaleAspectFit
//        animationView.loopMode = .playOnce
//
//        // 添加到指定的視圖（按鈕）
//        view.addSubview(animationView)
//
//        // 播放動畫
//        animationView.play { (finished) in
//            // 動畫結束後移除動畫視圖
//            animationView.removeFromSuperview()
//        }
//    }
//}
