//
//  Extensions+String.swift
//  Calendar
//
//  Created by Raphaël Huang-Dubois on 26/09/2023.
//

import Foundation

extension String {    
    func mapToDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        guard let date = dateFormatter.date(from: self) else {
            return Date()
        }
        return date
    }
}
