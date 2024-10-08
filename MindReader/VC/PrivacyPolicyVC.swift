//
//  PrivacyPolicyVC.swift
//  MindReader
//
//  Created by J oyce on 2024/10/8.
//

import Foundation
import UIKit
import WebKit

class PrivacyPolicyViewController: UIViewController {

    var webView: WKWebView!

    override func loadView() {
        webView = WKWebView()
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let htmlPath = Bundle.main.path(forResource: "privacy_policy", ofType: "html") {
            let url = URL(fileURLWithPath: htmlPath)
            let request = URLRequest(url: url)
            webView.load(request)
        } else {
            print("未找到 privacy_policy.html 文件")
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
}
