//
//  Extensions+String.swift
//  Calendar
//
//  Created by Raphaël Huang-Dubois on 26/09/2023.
//

import Foundation

extension String {    
    func mapToWeekdayDateComponents() -> DateComponents {
        let date = self.mapToDate()
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .weekday], from: date)
        return dateComponents
    }
    
    func mapToDailyDateComponents() -> DateComponents {
        let date = self.mapToDate()
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return dateComponents
    }
    
    func mapToDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        guard let date = dateFormatter.date(from: self) else {
            return Date()
        }
        return date
    }
}
