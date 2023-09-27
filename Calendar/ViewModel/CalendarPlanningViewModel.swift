//
//  CalendarPlanningViewModel.swift
//  Calendar
//
//  Created by Raphaël Huang-Dubois on 25/09/2023.
//

import SwiftUI

final class CalendarPlanningViewModel: ObservableObject {
    
    @Published var areHoursDisplayed = false
        
    private let calendarPlanning: CalendarPlanning
    private let calendar = Calendar.current
    
    var calendarStartingDate: Date {
        switch calendarPlanning.planningOption {
        case .weekly, .weeklyCustom:
            return calendarPlanning.weeklyStartingDate == nil ? Date() : calendarPlanning.weeklyStartingDate?.mapToDate() ?? Date()
        case .daily:
            return calendarPlanning.dailyPlanning.determineCalendarDates().startingDate
        }
    }
    
    var calendarEndingDate: Date {
        switch calendarPlanning.planningOption {
        case .weekly, .weeklyCustom:
            return calendarPlanning.weeklyEndingDate == nil ? calendar.date(byAdding: .year, value: 2, to: Date()) ?? Date() : calendarPlanning.weeklyEndingDate?.mapToDate() ?? Date()
        case .daily:
            return calendarPlanning.dailyPlanning.determineCalendarDates().endingDate
        }
    }
    
    init() {
        // Fetch data
        self.calendarPlanning = CalendarPlanning.dailyExample
    }
    
    func populateSelectableDates(given dateComponents: DateComponents?) -> Bool {
        switch calendarPlanning.planningOption {
        case .weekly:
            return populateWeeklyOption(dateComponents)
        case .weeklyCustom:
            return populateWeeklyCustomOption(dateComponents)
        case .daily:
            return populateDailyOption(dateComponents)
        }
    }
    
    private func populateWeeklyOption(_ dateComponents: DateComponents?) -> Bool {
        guard let dateComponents = dateComponents, let date = dateComponents.date else {
            return false
        }
        let selectable = calendar.dateComponents([.weekday], from: date)
        return getWeeklySelectableDateComponents().contains { $0 == selectable } ? true : false
    }
    
    private func populateWeeklyCustomOption(_ dateComponents: DateComponents?) -> Bool {
        guard let dateComponents = dateComponents, let date = dateComponents.date else {
            return false
        }
    
        let selectable = calendar.dateComponents([.weekday], from: date)
        let removable = calendar.dateComponents([.year, .month, .day], from: date)
        
        let firstCondition = getWeeklySelectableDateComponents().contains { $0 == selectable }
        let secondCondition = !getWeeklyRemovableDateComponents().contains { $0 == removable }
        
        return firstCondition && secondCondition ? true : false
    }
    
    private func populateDailyOption(_ dateComponents: DateComponents?) -> Bool {
        guard let dateComponents = dateComponents, let date = dateComponents.date else {
            return false
        }
        let selectable = calendar.dateComponents([.year, .month, .day], from: date)
        return getDailySelectableDateComponents().contains { $0 == selectable } ? true : false
    }
    
    private func getWeeklySelectableDateComponents() -> [DateComponents] {
        guard let weeklyPlanning = calendarPlanning.weeklyPlanning else {
            return []
        }
        
        var selectableDateComponents: [DateComponents] = []
        
        for (key, value) in weeklyPlanning {
            if !value.isEmpty {
                var dateComponents = DateComponents()
                dateComponents.weekday = key
                selectableDateComponents.append(dateComponents)
            }
        }
        return selectableDateComponents
    }
    
    private func getWeeklyRemovableDateComponents() -> [DateComponents] {
        guard let weeklyModifiedDates = calendarPlanning.weeklyModifiedDates else {
            return []
        }
        var removableDateComponents: [DateComponents] = []
        
        for (key, value) in weeklyModifiedDates {
            var dateComponents = DateComponents()
            if value.isEmpty {
                let date = key.splitDate()
                dateComponents.year = date.year
                dateComponents.month = date.month
                dateComponents.day = date.day
                removableDateComponents.append(dateComponents)
            }
        }
        return removableDateComponents
    }
    
    private func getDailySelectableDateComponents() -> [DateComponents] {
        guard let weeklyPlanning = calendarPlanning.dailyPlanning else {
            return []
        }
        
        var selectableDateComponents: [DateComponents] = []
        
        for key in weeklyPlanning.keys {
            var dateComponents = DateComponents()
            let date = key.splitDate()
            dateComponents.year = date.year
            dateComponents.month = date.month
            dateComponents.day = date.day
            selectableDateComponents.append(dateComponents)
        }
        return selectableDateComponents
    }
    
    func isDateInsideTimeInterval(given dateComponents: DateComponents) -> Bool {
        guard let otherDate = dateComponents.date else {
            return false
        }
        let startingDateComparison = calendar.compare(calendarStartingDate, to: otherDate, toGranularity: .day)
        let endingDateComparison = calendar.compare(calendarEndingDate, to: otherDate, toGranularity: .day)
        
        let firstCondition = startingDateComparison == .orderedAscending || startingDateComparison == .orderedSame
        let secondCondition = endingDateComparison == .orderedDescending || endingDateComparison == .orderedSame
       
        return firstCondition && secondCondition ? true : false
    }
    
    func determineDailyAvailabilities(given dateComponents: DateComponents) -> Int {
        guard let date = dateComponents.date else {
            return 0
        }
        
        switch calendarPlanning.planningOption {
        case .weekly, .weeklyCustom:
           guard let weeklyPlanning = calendarPlanning.weeklyPlanning,
                 let weekday = dateComponents.weekday else {
                return 0
            }
            let dateComponents = calendar.dateComponents([.weekday], from: date)
            return weeklyPlanning[weekday]?.count ?? 0
        case.daily:
            guard let dailyPlanning = calendarPlanning.dailyPlanning else {
                 return 0
             }
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            return dailyPlanning[dateComponents.mapToString()]?.count ?? 0
        }
    }
}
