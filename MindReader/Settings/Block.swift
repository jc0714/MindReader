//
//  Block.swift
//  MindReader
//
//  Created by J oyce on 2024/10/2.
//

import Foundation

func block() {
    var blockedList = UserDefaults.standard.stringArray(forKey: "BlockedList") ?? []
    print("Blocked Users: \(blockedList)")

    let userIdToRemove = "A1578E48-486F-4989-A1FD-AA52783B9924"

    // 檢查並移除指定的值
    if let index = blockedList.firstIndex(of: userIdToRemove) {
        blockedList.remove(at: index)

        // 更新 UserDefaults
        UserDefaults.standard.set(blockedList, forKey: "BlockedList")
        print("\(userIdToRemove) has been removed from the blocked list.")
    } else {
        print("\(userIdToRemove) not found in the blocked list.")
    }
}
