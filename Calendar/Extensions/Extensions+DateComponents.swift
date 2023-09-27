//
//  Extensions+DateComponents.swift
//  Calendar
//
//  Created by Raphaël Huang-Dubois on 27/09/2023.
//

import Foundation

extension DateComponents {
    func mapToString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        guard let date = Calendar.current.date(from: self) else { return "" }
        return dateFormatter.string(from: date)
    }
}
