//
//  MorningWidget.swift
//  MorningWidget
//
//  Created by J oyce on 2024/10/6.
//

import WidgetKit
import SwiftUI
import FirebaseCore

struct Provider: TimelineProvider {

    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), encouragement: "今天也順心❤️")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), encouragement: "日日是好日")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            var entries: [SimpleEntry] = []
            let currentDate = Date()

            for dayOffset in 0 ..< 7 {
                let entryDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate)!

                // 使用 async/await 來處理異步操作
                let encouragement = await EncouragementService.dailyEncouragement(for: entryDate)

                let entry = SimpleEntry(date: entryDate, encouragement: encouragement)
                entries.append(entry)
            }

            // 建立時間軸並回傳
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }

    // 每日隨機背景圖片的邏輯
    func dailyBackgroundImage(for date: Date) -> String {
        let backgroundImages = ["photo1", "photo2", "photo3", "photo4", "photo5", "photo6", "photo7", "photo8", "photo9", "photo10", "photo11"]

        // 使用日期的 day, month, year 組成一個隨機但固定的索引
        let day = Calendar.current.component(.day, from: date)
        let month = Calendar.current.component(.month, from: date)
        let year = Calendar.current.component(.year, from: date)

        let index = (day + month + year) % backgroundImages.count

        return backgroundImages[index]
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let encouragement: String
}

struct MorningWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        ZStack {
            // 每日隨機背景圖
            Image(dailyBackgroundImage(for: entry.date))
                .resizable()
                .scaledToFill()
                .frame(width: widgetFamily == .systemSmall ? 158 : 340, height: widgetFamily == .systemSmall ? 158 : 158) // 放大一點圖片
                .clipped()
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.2))

            VStack(spacing: 8) {
                // 顯示「星期幾」
                Text(weekdayInChinese(from: entry.date))
                    .font(.system(size: widgetFamily == .systemSmall ? 30 : 30, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)

                // 顯示本日鼓勵語
                Text(entry.encouragement)
                    .font(.system(size: widgetFamily == .systemSmall ? 20 : 22, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
                    .padding([.leading, .trailing], 0.01)
            }
            .padding(0)
        }
    }

    // 自定義方法來顯示中文的星期幾
    private func weekdayInChinese(from date: Date) -> String {
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: date)
        let weekdays = ["星期天☀️", "星期一⛽️", "星期二🍀", "星期三💪🏻", "星期四💡", "星期五🍕", "星期六🏖️"]
        return weekdays[dayOfWeek - 1]
    }

    // 每日隨機圖片
    private func dailyBackgroundImage(for date: Date) -> String {
        // 把圖片名稱的初始化和計算分開
        let imageNames: [String] = [
            "photo1", "photo2", "photo3", "photo4",
            "photo5", "photo6", "photo7", "photo8",
            "photo9", "photo10", "photo11"
        ]

        // 根據日期計算一個索引
        let day = Calendar.current.component(.day, from: date)
        let month = Calendar.current.component(.month, from: date)
        let year = Calendar.current.component(.year, from: date)

        // 計算圖片索引，確保範圍在 imageNames 數組內
        let index = (day + month + year) % imageNames.count

        return imageNames[index]
    }
}

struct MorningWidget: Widget {
    let kind: String = "MorningWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MorningWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("早安圖")
        .description("日日是好日，來點力量！")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemSmall) {
    MorningWidget()
} timeline: {
    SimpleEntry(date: .now, encouragement: "Happy Friday！一定要吃個好吃晚餐，配電影")
}

#Preview(as: .systemMedium) {
    MorningWidget()
} timeline: {
    SimpleEntry(date: .now, encouragement: "快樂星期五，一定要吃個好吃晚餐，配個好看電影")
}
