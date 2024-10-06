//
//  RecordVC.swift
//  MindReader
//
//  Created by J oyce on 2024/9/19.
//

import Foundation
import UIKit

class RecordVC: UIViewController {

    private let albumVC = AlbumVC()
    private let myPostVC = MyPostVC()

    private let RView = RecordView()
    private var currentVC: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupRecordView()
        displayContentController(albumVC)
    }

    private func setupRecordView() {
        RView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(RView)

        NSLayoutConstraint.activate([
            RView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            RView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            RView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            RView.heightAnchor.constraint(equalToConstant: 50)
        ])
        RView.setData()

        RView.buttons.forEach { button in
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        }
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        let newIndex = sender.tag

        if newIndex == 0 {
            switchToContentController(albumVC)
        } else if newIndex == 1 {
            switchToContentController(myPostVC)
        }

        RView.updateIndicator(forIndex: newIndex)
    }

    private func displayContentController(_ content: UIViewController) {
        addChild(content)
        view.addSubview(content.view)

        content.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            content.view.topAnchor.constraint(equalTo: RView.bottomAnchor),
            content.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            content.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            content.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        content.didMove(toParent: self)
        currentVC = content
    }

    private func switchToContentController(_ newVC: UIViewController) {
        guard let currentVC = currentVC else {
            displayContentController(newVC)
            return
        }

        currentVC.willMove(toParent: nil)
        addChild(newVC)

        transition(from: currentVC, to: newVC, duration: 0.3, options: [.transitionCrossDissolve], animations: nil) { completed in
            currentVC.view.removeFromSuperview()
            currentVC.removeFromParent()
            newVC.didMove(toParent: self)
            self.currentVC = newVC
        }

        newVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            newVC.view.topAnchor.constraint(equalTo: RView.bottomAnchor),
            newVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// 因為手勢會衝突，所以先不使用 pageView controller

//class RecordVC: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
//
//    private let albumVC = AlbumVC()
//    private let myPostVC = MyPostVC()
//
//    private let RView = RecordView()
//    private var pageViewController: UIPageViewController!
//    private var viewControllers: [UIViewController] = []
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        setupRecordView()
//        setupPageViewController()
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        // 設定手勢優先級
//        for gesture in pageViewController.view.gestureRecognizers ?? [] {
//            gesture.isEnabled = false
//        }
//    }
//
//    private func setupRecordView() {
//        RView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(RView)
//
//        NSLayoutConstraint.activate([
//            RView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            RView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            RView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            RView.heightAnchor.constraint(equalToConstant: 50)
//        ])
//        RView.setData()
//
//        RView.buttons.forEach { button in
//            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
//        }
//    }
//
//    private func setupPageViewController() {
//        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
//        pageViewController.dataSource = self
//        pageViewController.delegate = self
//
//        addChild(pageViewController)
//        view.addSubview(pageViewController.view)
//
//        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            pageViewController.view.topAnchor.constraint(equalTo: RView.bottomAnchor),
//            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//        pageViewController.didMove(toParent: self)
//
//        // 設定手勢優先級
//        for gesture in pageViewController.view.gestureRecognizers ?? [] {
//            gesture.isEnabled = false
//        }
//
//        viewControllers = [albumVC, myPostVC]
//        pageViewController.setViewControllers([albumVC], direction: .forward, animated: false, completion: nil)
//    }
//
//    @objc private func buttonTapped(_ sender: UIButton) {
//        let newIndex = sender.tag
//        let currentIndex = viewControllers.firstIndex(of: pageViewController.viewControllers!.first!) ?? 0
//
//        if newIndex != currentIndex {
//            let direction: UIPageViewController.NavigationDirection = newIndex > currentIndex ? .forward : .reverse
//            pageViewController.setViewControllers([viewControllers[newIndex]], direction: direction, animated: true, completion: nil)
//            RView.updateIndicator(forIndex: newIndex)
//        }
//    }
//
//    // MARK: - UIPageViewControllerDataSource
//
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
//        guard let index = viewControllers.firstIndex(of: viewController), index > 0 else {
//            return nil
//        }
//        return viewControllers[index - 1]
//    }
//
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
//        guard let index = viewControllers.firstIndex(of: viewController), index < viewControllers.count - 1 else {
//            return nil
//        }
//        return viewControllers[index + 1]
//    }
//
//    // MARK: - UIPageViewControllerDelegate
//
//    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
//        if completed, let currentVC = pageViewController.viewControllers?.first, let index = viewControllers.firstIndex(of: currentVC) {
//            RView.updateIndicator(forIndex: index)
//        }
//    }
//}
