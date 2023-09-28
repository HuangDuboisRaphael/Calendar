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
        case .weekly:
            return calendarPlanning.weeklyStartingDate == nil ? Date() : calendarPlanning.weeklyStartingDate?.mapToDate() ?? Date()
        case .daily:
            return calendarPlanning.dailyPlanning.determineCalendarDates().startingDate
        }
    }
    
    var calendarEndingDate: Date {
        switch calendarPlanning.planningOption {
        case .weekly:
            return calendarPlanning.weeklyEndingDate == nil ? calendar.date(byAdding: .year, value: 2, to: Date()) ?? Date() : calendarPlanning.weeklyEndingDate?.mapToDate() ?? Date()
        case .daily:
            return calendarPlanning.dailyPlanning.determineCalendarDates().endingDate
        }
    }
    
    init() {
        // Fetch data
        self.calendarPlanning = CalendarPlanning.weeklyExample
    }
    
    func populateCalendar(given dateComponents: DateComponents?) -> Bool {
        guard let dateComponents = dateComponents, let date = dateComponents.date else {
            return false
        }
        switch calendarPlanning.planningOption {
        case .weekly:
            return populateWeeklyCalendar(with: date)
        case .daily:
            return populateDailyCalendar(with: date)
        }
    }
    
    private func populateWeeklyCalendar(with date: Date) -> Bool {
        guard let _ = calendarPlanning.weeklyModifiedDates else {
            return populateWeeklyCalendarWithoutModifiedDates(date: date)
        }

        var selectableDateComponents = transformWeeklyToDailyDateComponents(date: date)
        let modifiedDateComponents = sortModifiedDateComponents()
        
        // If predifined weekday components doesn't contain selectable modified dates components, add it in the selectable array.
        for component in modifiedDateComponents.selectable {
            if !selectableDateComponents.contains(component) {
                selectableDateComponents.append(component)
            }
        }
        
        let dateComponents = calendar.dateComponents([.year, .month, .day, .weekday], from: date)
        let selectable = selectableDateComponents.contains { $0 == dateComponents }
        let removable = !modifiedDateComponents.removable.contains { $0 == dateComponents }
        
        return selectable && removable ? true : false
    }
    
    private func populateWeeklyCalendarWithoutModifiedDates(date: Date) -> Bool {
        guard let weeklyPlanning = calendarPlanning.weeklyPlanning else {
            return false
        }
        
        var array: [DateComponents] = []
        
        for (key, value) in weeklyPlanning {
            if !value.isEmpty {
                var dateComponents = DateComponents()
                dateComponents.weekday = key
                array.append(dateComponents)
            }
        }
        let dateComponents = calendar.dateComponents([.weekday], from: date)
        return array.contains { $0 == dateComponents } ? true : false
    }
    
    // To tranform only weekday date components to complete one to identify if user has added dates on their predifined not working weekdays.
    private func transformWeeklyToDailyDateComponents(date: Date) -> [DateComponents] {
        var array: [DateComponents] = []
        let dateComponents = calendar.dateComponents([.year, .month, .day, .weekday], from: date)
        if calendarPlanning.weeklyPlanning.determineWeekdays().contains(dateComponents.weekday ?? 0) {
            array.append(dateComponents)
        }
        return array
    }
    
    // To sort the modified dates dictionary into selectable and removable dates components to future display on calendar.
    private func sortModifiedDateComponents() -> (selectable: [DateComponents], removable: [DateComponents]) {
        var selectableDateComponents: [DateComponents] = []
        var removableDateComponents: [DateComponents] = []
        
        for (key, value) in calendarPlanning.weeklyModifiedDates! {
            if !value.isEmpty {
                selectableDateComponents.append(key.mapToWeekdayDateComponents())
            } else {
                removableDateComponents.append(key.mapToWeekdayDateComponents())
            }
        }
        return (selectable: selectableDateComponents, removable: removableDateComponents)
    }
    
    private func populateDailyCalendar(with date: Date) -> Bool {
        guard let weeklyPlanning = calendarPlanning.dailyPlanning else {
            return false
        }
        var array: [DateComponents] = []
        
        for key in weeklyPlanning.keys {
            array.append(key.mapToDailyDateComponents())
        }
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        return array.contains { $0 == dateComponents } ? true : false
    }
}
