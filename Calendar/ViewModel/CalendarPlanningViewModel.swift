//
//  CalendarPlanningViewModel.swift
//  Calendar
//
//  Created by Raphaël Huang-Dubois on 25/09/2023.
//

import SwiftUI

final class CalendarPlanningViewModel: ObservableObject {
        
    private let calendarPlanning: CalendarPlanning
    private let calendar = Calendar.current
    var twoYearsFromToday: Date {
        calendar.date(byAdding: .year, value: 2, to: Date()) ?? Date()
    }
    
    init() {
        // Fetch data
        self.calendarPlanning = CalendarPlanning.weeklyExample
    }
    
    func canSelectWeekdays(with dateComponents: DateComponents?) -> Bool {
        guard let weeklyPlanning = calendarPlanning.weeklyPlanning, var dateComponents = dateComponents else {
            return false
        }
        
        var storage: [DateComponents] = []
        
        for (key, value) in weeklyPlanning {
            if !value.isEmpty {
                var dateComponents = DateComponents()
                dateComponents.weekday = key
                storage.append(dateComponents)
            }
        }
    
        dateComponents = calendar.dateComponents([.weekday], from: dateComponents.date ?? Date())
        return !storage.contains { $0 == dateComponents } ? false : true
    }
    
    func isFutureDate(given dateComponents: DateComponents) -> Bool {
        guard let otherDate = dateComponents.date else {
            return false
        }
        let today = Date()
        let comparison = calendar.compare(today, to: otherDate, toGranularity: .day)
       
        return comparison == .orderedAscending || comparison == .orderedSame ? true : false
    }
    
    func numberOfAvailabilities(given dateComponents: DateComponents) -> Int {
        guard let date = dateComponents.date,
              let weeklyPlanning = calendarPlanning.weeklyPlanning else {
            return 0
        }
        
        let dateComponents = calendar.dateComponents([.weekday], from: date)
        guard let weekday = dateComponents.weekday else {
            return 0
        }
        
        return weeklyPlanning[weekday]?.count ?? 0
    }
}
