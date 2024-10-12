//
//  MorningWidget.swift
//  MorningWidget
//
//  Created by J oyce on 2024/10/6.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), encouragement: "今天也順心❤️")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), encouragement: "日日是好日")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        let currentDate = Date()
        for dayOffset in 0 ..< 7 {
            let entryDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate)!
            let encouragement = dailyEncouragement(for: entryDate)
            let entry = SimpleEntry(date: entryDate, encouragement: encouragement)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    func dailyEncouragement(for date: Date) -> String {
        let dayOfWeek = Calendar.current.component(.weekday, from: date)
        switch dayOfWeek {
        case 1:
            return "放鬆心情，享受生活！🐷"
        case 2:
            return "週一來了！新的一週也加油🌱"
        case 3:
            return "週二適合吃個好吃的午餐，配上一杯健康果汁🍹"
        case 4:
            return "這週已經過了一半，耶吼～🤩"
        case 5:
            return "週四，快要到週末了，撐住！（酪梨健康好吃🥑）"
        case 6:
            return "Happy Friday，一定要吃個好吃晚餐，配個好看電影🎬"
        case 7:
            return "今天可以睡飽一點，做點喜歡的事情！🍺"
        default:
            return "每天都是好日子，一起快樂過生活"
        }
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
            Color.yellow // 使用單一背景色，便於文字顯示清晰

            VStack(spacing: 8) { // 設置字行間距
                // 顯示「星期幾」並讓它佔滿第一行
                Text(weekdayInChinese(from: entry.date))
                    .font(.system(size: widgetFamily == .systemSmall ? 36 : 30, weight: .bold)) // 調整字體大小和粗細
                    .lineLimit(1) // 確保文字佔一行
                    .minimumScaleFactor(0.5) // 文字自動縮放以適應空間
                    .frame(maxWidth: .infinity) // 佔滿整個寬度
                    .foregroundColor(.white)

                // 顯示本日鼓勵語
                Text(entry.encouragement)
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(3) // 最多顯示三行
                    .minimumScaleFactor(0.8) // 文字自動縮小以適應空間
                    .padding([.leading, .trailing], 0.01) // 加入左右邊距，讓文字不貼邊
            }
            .padding(.vertical, 10) // 減少上下 padding，避免過多空間
        }
        .containerBackground(Color.yellow, for: .widget) // 設定背景顏色
    }

    // 自定義方法來顯示中文的星期幾
    private func weekdayInChinese(from date: Date) -> String {
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: date)
        let weekdays = ["星期天☀️", "星期一⛽️", "星期二🍀", "星期三💪🏻", "星期四💡", "星期五🍕", "星期六🏖️"]
        return weekdays[dayOfWeek - 1]
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
