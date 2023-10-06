//
//  Extensions+Dictionary.swift
//  Calendar
//
//  Created by Raphaël Huang-Dubois on 27/09/2023.
//

import Foundation

extension Dictionary<Int, [String]> {
    func determineWeekdays() -> [Int] {
        var weekdays: [Int] = []
        for (key, value) in self {
            if !value.isEmpty {
                weekdays.append(key)
            }
        }
        return weekdays
    }
}
