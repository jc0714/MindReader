//
//  DateFormatterExtension.swift
//  MindReader
//
//  Created by J oyce on 2024/9/24.
//

import Foundation

extension DateFormatter {
    static let sharedFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm" // 可調整為"yyyy-MM-ddHH:mm:ss"
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        return formatter
    }()

    static let yyyyMMddFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        return formatter
    }()

}
