//
//  LoginVC.swift
//  MindReader
//
//  Created by J oyce on 2024/9/26.
//

import Foundation
import UIKit
import AuthenticationServices
import Firebase

class LoginVC: UIViewController, ASAuthorizationControllerPresentationContextProviding {

    let appleSignInButton = ASAuthorizationAppleIDButton()
    private let firebaseService = FirestoreService()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        // 設置背景顏色
        self.view.backgroundColor = .white // 確保背景是白色

        // 配置蘋果登入按鈕
        configureAppleSignInButton()
    }

    private func configureAppleSignInButton() {
        appleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(appleSignInButton)

        if #available(iOS 13.0, *) {
            appleSignInButton.isHidden = false
            appleSignInButton.addTarget(self, action: #selector(pressSignInWithAppleButton), for: .touchUpInside)
        } else {
            appleSignInButton.isHidden = true
        }

        // 設置按鈕在背景視圖的中心
        NSLayoutConstraint.activate([
            appleSignInButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            appleSignInButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }

    @objc private func pressSignInWithAppleButton() {
        let authorizationAppleIDRequest = ASAuthorizationAppleIDProvider().createRequest()
        authorizationAppleIDRequest.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [authorizationAppleIDRequest])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension LoginVC: ASAuthorizationControllerDelegate {

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {

        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            print("user: \(appleIDCredential.user)")
            print("fullName: \(String(describing: appleIDCredential.fullName))")
            print("Email: \(String(describing: appleIDCredential.email))")

            let lastName = appleIDCredential.fullName?.familyName ?? "UUser"
            let email = appleIDCredential.email
            let realUserStatus = appleIDCredential.realUserStatus.rawValue

            // 查詢 Firestore 以確認用戶是否已存在
            let usersCollection = Firestore.firestore().collection("Users")
            usersCollection.whereField("user", isEqualTo: userIdentifier).getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error checking if user exists: \(error.localizedDescription)")
                    return
                }
                // 用戶不存在
                if let snapshot = snapshot, snapshot.documents.isEmpty {
                    self.firebaseService.saveUserInfoToFirestore(userIdentifier: userIdentifier, fullName: lastName, email: email, realUserStatus: realUserStatus)

                    UserDefaults.standard.set(lastName, forKey: "userLastName")
                    UserDefaults.standard.set(userIdentifier, forKey: "appleUserIdentifier")
                    UserDefaults.standard.synchronize()
                } else {
                    // 用戶已經存在
                    if let document = snapshot?.documents.first {
                    let existingUserId = document.documentID
                    UserDefaults.standard.set(existingUserId, forKey: "userId")
                    UserDefaults.standard.synchronize()

                    print("User already exists in Firestore. UserId saved to UserDefaults.")
                    }
                }
            }
        }

        UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
        
        DispatchQueue.main.async {
            // 获取 Main Storyboard
            let storyboard = UIStoryboard(name: "Main", bundle: nil)

            // 获取 Tab Bar Controller
            guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController else {
                print("无法找到 MainTabBarController")
                return
            }

            // 设置根视图控制器为 Tab Bar Controller
            UIApplication.shared.windows.first?.rootViewController = tabBarController

            // 添加转场动画（可选）
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }

        // 登入成功後，關閉 LoginViewController
//        self.dismiss(animated: true, completion: nil)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("didCompleteWithError: \(error.localizedDescription)")
    }
}
