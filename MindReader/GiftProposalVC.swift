//
//  GiftProposalVC.swift
//  MindReader
//
//  Created by J oyce on 2024/9/14.
//

//import UIKit
//
//class GiftProposalVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
//
//    private let proposals = (1...100).map { "送禮提案 \($0)" }
//    private var tableView: UITableView!
//    private let drawButton = UIButton(type: .system)
//
//    private var timer: Timer?
//    private var currentIndex = 0
//    private var remainingCycles = 0
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupView()
//    }
//
//    private func setupView() {
//        view.backgroundColor = .white
//
//        tableView = UITableView(frame: .zero, style: .plain)
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.isScrollEnabled = false
//        tableView.separatorStyle = .none
//        tableView.showsVerticalScrollIndicator = false
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
//        view.addSubview(tableView)
//
//        drawButton.setTitle("抽卡", for: .normal)
//        drawButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
//        drawButton.addTarget(self, action: #selector(drawProposal), for: .touchUpInside)
//        drawButton.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(drawButton)
//
//        NSLayoutConstraint.activate([
//            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            tableView.widthAnchor.constraint(equalToConstant: 300),
//            tableView.heightAnchor.constraint(equalToConstant: 120), // 限制高度显示三个选项
//
//            drawButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            drawButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
//            drawButton.widthAnchor.constraint(equalToConstant: 120),
//            drawButton.heightAnchor.constraint(equalToConstant: 50)
//        ])
//    }
//
//    // MARK: - 抽卡邏輯
//
//    @objc private func drawProposal() {
//        guard timer == nil else { return }  // 防止重複 click
//
//        // 初始化滾動效果參數
//        remainingCycles = Int.random(in: 30...50)  // 控制滚次數
//        currentIndex = 0
//
//        // 每0.05秒更新一次
//        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateTableView), userInfo: nil, repeats: true)
//    }
//
//    @objc private func updateTableView() {
//        currentIndex = (currentIndex + 1) % proposals.count
//        tableView.reloadData()
//
//        let indexPath = IndexPath(row: currentIndex, section: 0)
//        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
//
//        remainingCycles -= 1
//
//        if remainingCycles <= 0 {
//            timer?.invalidate()
//            timer = nil
//            finalizeProposal()
//        } else {
//            let newTimeInterval = min(0.05 * Double(remainingCycles) / 10.0, 0.5)
//            timer?.invalidate()
//            timer = Timer.scheduledTimer(timeInterval: newTimeInterval, target: self, selector: #selector(updateTableView), userInfo: nil, repeats: true)
//        }
//    }
//
//    private func finalizeProposal() {
//        print("最终結果是：\(proposals[currentIndex])")
//    }
//
//    // MARK: - UITableViewDataSource 和 UITableViewDelegate
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return proposals.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        cell.textLabel?.text = proposals[indexPath.row]
//        cell.textLabel?.textAlignment = .center
//        cell.textLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
//
//        let distanceFromCenter = abs(currentIndex - indexPath.row)
//        cell.textLabel?.alpha = 1.0 - CGFloat(distanceFromCenter) * 0.05
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 40
//    }
//}
