//
//  Extensions+String.swift
//  Calendar
//
//  Created by Raphaël Huang-Dubois on 26/09/2023.
//

import Foundation

extension String {
    func splitDate() -> (day: Int, month: Int, year: Int) {
        let dateComponents = self.split(separator: "/")
        
        guard let day = Int(dateComponents[0]),
              let month = Int(dateComponents[1]),
              let year = Int(dateComponents[2]) else {
            return (0, 0, 0)
        }
        
        return (day, month, year)
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
