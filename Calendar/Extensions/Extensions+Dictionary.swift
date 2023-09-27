//
//  Extensions+Dictionary.swift
//  Calendar
//
//  Created by Raphaël Huang-Dubois on 27/09/2023.
//

import Foundation

extension Dictionary<String, [String]>? {
    func determineCalendarDates() -> (startingDate: Date, endingDate: Date) {
        guard let self = self else {
            return (startingDate: Date(), endingDate: Date())
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"

        var dates: [Date] = []
        for date in self.keys {
            if let date = dateFormatter.date(from: date) {
                dates.append(date)
            }
        }
        guard let startingDate = dates.min(), let endingDate = dates.max() else {
            return (startingDate: Date(), endingDate: Date())
        }
        return (startingDate: startingDate, endingDate: endingDate)
    }
}
