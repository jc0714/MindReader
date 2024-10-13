//
//  EncouragementProvider.swift
//  MindReader
//
//  Created by J oyce on 2024/10/13.
//

import Foundation
import Firebase
import FirebaseFirestore

class EncouragementService {

    static func dailyEncouragement(for date: Date) async -> String {
        let dayOfWeek = Calendar.current.component(.weekday, from: date)

        // 檢查當天的資料是否已緩存
        let lastFetchDate = UserDefaults.standard.object(forKey: "lastFetchDate") as? Date ?? Date.distantPast
        let today = Calendar.current.startOfDay(for: date)

        if lastFetchDate < today {
            // 如果今天還沒有抓取資料，從 Firebase 抓取
            let db = Firestore.firestore()
            let documentRef = db.collection("WidgetDB").document("\(dayOfWeek)") // 使用 dayOfWeek 作為 document ID

            do {
                let document = try await documentRef.getDocument()
                if let messages = document.data()?["messages"] as? [String] {
                    // 隨機選擇一條鼓勵語
                    let randomMessage = messages.randomElement() ?? "日日是好日，今天也會順利的🍀"

                    // 緩存抓取的數據和日期
                    UserDefaults.standard.set(messages, forKey: "cachedMessages")
                    UserDefaults.standard.set(today, forKey: "lastFetchDate")

                    return randomMessage
                }
            } catch {
                print("Error fetching document: \(error)")
            }
        }

        // 如果已有緩存，從本地讀取隨機一條
        let cachedMessages = UserDefaults.standard.array(forKey: "cachedMessages") as? [String] ?? []
        return cachedMessages.randomElement() ?? "日日是好日，今天也會順利的🍀"
    }
}
