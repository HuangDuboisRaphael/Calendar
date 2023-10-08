//
//  Extensions+Date.swift
//  Calendar
//
//  Created by Raphaël Huang-Dubois on 08/10/2023.
//

import Foundation

extension Date {
    enum DateFormatType {
        case day
        case weekday
        case month
    }
    
    func mapToString(_ type: DateFormatType) -> String {
        switch type {
        case .day:
            return DateFormatter(dateFormat: "d").string(from: self)
        case .weekday:
            return DateFormatter(dateFormat: "EEEEE").string(from: self)
        case .month:
            let lowercased = DateFormatter(dateFormat: "MMMM yyyy").string(from: self)
            let uppercased = lowercased.prefix(1).uppercased() + lowercased.dropFirst()
            return uppercased
        }
    }
}

private extension DateFormatter {
    convenience init(dateFormat: String) {
        self.init()
        self.locale = LocaleHelper.preferredLocale
        self.dateFormat = dateFormat
    }
}
