//
//  RecordVC.swift
//  MindReader
//
//  Created by J oyce on 2024/9/19.
//

import Foundation
import UIKit

//class RecordVC: UIViewController {
//
//    private let albumVC = AlbumVC()
//    private let myPostVC = MyPostVC()
//
//    private let RView = RecordView()
//    private var currentVC: UIViewController?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        setupRecordView()
//        displayContentController(albumVC)
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
//    @objc private func buttonTapped(_ sender: UIButton) {
//        let newIndex = sender.tag
//
//        if newIndex == 0 {
//            switchToContentController(albumVC)
//        } else if newIndex == 1 {
//            switchToContentController(myPostVC)
//        }
//
//        RView.updateIndicator(forIndex: newIndex)
//    }
//
//    private func displayContentController(_ content: UIViewController) {
//        addChild(content)
//        view.addSubview(content.view)
//
//        content.view.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            content.view.topAnchor.constraint(equalTo: RView.bottomAnchor),
//            content.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            content.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            content.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//
//        content.didMove(toParent: self)
//        currentVC = content
//    }
//    private func switchToContentController(_ newVC: UIViewController) {
//        guard let currentVC = currentVC else {
//            displayContentController(newVC)
//            return
//        }
//
//        // Prepare the new view controller
//        addChild(newVC)
//        view.addSubview(newVC.view)
//
//        newVC.view.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            newVC.view.topAnchor.constraint(equalTo: RView.bottomAnchor),
//            newVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            newVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            newVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//
//        // Perform the transition
//        transition(from: currentVC, to: newVC, duration: 0.3, options: [.transitionCrossDissolve], animations: nil) { completed in
//            // Cleanup the current view controller
//            currentVC.view.removeFromSuperview()
//            currentVC.removeFromParent()
//            newVC.didMove(toParent: self)
//            self.currentVC = newVC
//        }
//    }
////    private func switchToContentController(_ newVC: UIViewController) {
////        guard let currentVC = currentVC else {
////            displayContentController(newVC)
////            return
////        }
////
////        currentVC.willMove(toParent: nil)
////        addChild(newVC)
////
////        transition(from: currentVC, to: newVC, duration: 0.3, options: [.transitionCrossDissolve], animations: nil) { completed in
////            currentVC.view.removeFromSuperview()
////            currentVC.removeFromParent()
////            newVC.didMove(toParent: self)
////            self.currentVC = newVC
////        }
////
////        newVC.view.translatesAutoresizingMaskIntoConstraints = false
////        NSLayoutConstraint.activate([
////            newVC.view.topAnchor.constraint(equalTo: RView.bottomAnchor),
////            newVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
////            newVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
////            newVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
////        ])
////    }
//}

// 因為手勢會衝突，所以先不使用 pageView controller

class RecordVC: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIGestureRecognizerDelegate {
    var currentPageIndex = 0

    private let albumVC = AlbumVC()
    private let myPostVC = MyPostVC()

    private let RView = RecordView()
    var pageViewController: UIPageViewController!
    lazy var viewControllers: [UIViewController] = [albumVC, myPostVC]

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .milkYellow

        setupRecordView()
        setupPageViewController()
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

    private func setupPageViewController() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self

        addChild(pageViewController)
        view.addSubview(pageViewController.view)

        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: RView.bottomAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        pageViewController.didMove(toParent: self)
        pageViewController.setViewControllers([albumVC], direction: .forward, animated: false, completion: nil)

        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        swipeGesture.direction = .right
        pageViewController.view.addGestureRecognizer(swipeGesture)
    }

    @objc private func handleSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
        if currentPageIndex == 1 { // 只在第二頁（索引 1）時觸發
            pageViewController.setViewControllers([viewControllers[0]], direction: .reverse, animated: true, completion: nil)
            RView.updateIndicator(forIndex: 0)
            currentPageIndex = 0
            updateScrollViewInteraction(forIndex: 0)
        }
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        let newIndex = sender.tag
        let currentIndex = viewControllers.firstIndex(of: pageViewController.viewControllers!.first!) ?? 0

        if newIndex != currentIndex {
            let direction: UIPageViewController.NavigationDirection = newIndex > currentIndex ? .forward : .reverse
            pageViewController.setViewControllers([viewControllers[newIndex]], direction: direction, animated: true, completion: nil)
            RView.updateIndicator(forIndex: newIndex)
            updateScrollViewInteraction(forIndex: newIndex)
        }
    }

    // MARK: - UIPageViewControllerDataSource

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllers.firstIndex(of: viewController), index > 0 else {
            return nil
        }
        return viewControllers[index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllers.firstIndex(of: viewController), index < viewControllers.count - 1 else {
            return nil
        }

        return viewControllers[index + 1]
    }

    // MARK: - UIPageViewControllerDelegate
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let currentVC = pageViewController.viewControllers?.first, let index = viewControllers.firstIndex(of: currentVC) {
            RView.updateIndicator(forIndex: index)
            currentPageIndex = index
            updateScrollViewInteraction(forIndex: index) // 更新滑動手勢狀態
        }
    }

    // MARK: - UIGestureRecognizerDelegate
    private func updateScrollViewInteraction(forIndex index: Int) {
        for view in pageViewController.view.subviews {
            if let scrollView = view as? UIScrollView {
                if index == 1 {
                    // 如果是第二頁，禁用滑動手勢
                    scrollView.isScrollEnabled = false
                } else {
                    // 如果不是第二頁，啟用滑動手勢
                    scrollView.isScrollEnabled = true
                } // 如果是第二頁（索引 1），禁用滑動手勢
            }
        }
    }
}
