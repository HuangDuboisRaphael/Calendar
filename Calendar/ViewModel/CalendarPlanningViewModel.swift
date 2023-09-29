//
//  CalendarPlanningViewModel.swift
//  Calendar
//
//  Created by Raphaël Huang-Dubois on 25/09/2023.
//

import SwiftUI

final class CalendarPlanningViewModel: ObservableObject {
    
    @Published var selectableDates = Dictionary<DateComponents, [String]>()
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
            return populateWeeklyCalendarWithoutModifiedDates(with: date)
        }

        var selectableDateComponents = transformWeeklyToDailyDateComponents(with: date)
        let modifiedDateComponents = sortModifiedDateComponents()
        
        // If predifined weekday components doesn't contain selectable modified dates components, add it in the selectable array.
        for (component, dates) in modifiedDateComponents.selectable {
            if !selectableDateComponents.keys.contains(component) {
                selectableDateComponents[component] = dates
            }
        }
        
        // To remove entire booked dates from selectable dictionary since user cannot interact with it.
        let bookedDateComponents = getBookedDateComponents()
        for component in bookedDateComponents.keys {
            if selectableDateComponents.keys.contains(component) {
                if selectableDateComponents[component]?.count == bookedDateComponents[component]?.count {
                    selectableDateComponents.removeValue(forKey: component)
                }
            }
        }
        // To assign the final selectable dates as published value.
        selectableDates = selectableDateComponents
        
        // To display selectable dates (weeklyPlanning + weeklyModifiedDates) and hide removable dates (weeklyModifiedDates + bookedDates)
        let givenDateComponents = calendar.dateComponents([.year, .month, .day, .weekday], from: date)
        let selectable = selectableDateComponents[givenDateComponents] != nil ? true : false
        let removable = modifiedDateComponents.removable[givenDateComponents] == nil ? true : false
        
        return selectable && removable ? true : false
    }
    
    private func populateWeeklyCalendarWithoutModifiedDates(with date: Date) -> Bool {
        guard let weeklyPlanning = calendarPlanning.weeklyPlanning else {
            return false
        }
        
        var dictionary = Dictionary<DateComponents, [String]>()
        for (date, hours) in weeklyPlanning {
            if !hours.isEmpty {
                var dateComponents = DateComponents()
                dateComponents.weekday = date
                dictionary[dateComponents] = hours
            }
        }
        
        let dateComponents = calendar.dateComponents([.weekday], from: date)
        return dictionary[dateComponents] != nil ? true : false
    }
    
    // To tranform only weekday date components to complete one to identify if user has added dates on their unworking weekdays.
    private func transformWeeklyToDailyDateComponents(with date: Date) -> Dictionary<DateComponents, [String]> {
        guard let weeklyPlanning = calendarPlanning.weeklyPlanning else {
            return Dictionary<DateComponents, [String]>()
        }
        var dictionary = Dictionary<DateComponents, [String]>()
        let dateComponents = calendar.dateComponents([.year, .month, .day, .weekday], from: date)
        if weeklyPlanning.determineWeekdays().contains(dateComponents.weekday ?? 0) {
            dictionary[dateComponents] = weeklyPlanning[dateComponents.weekday ?? 0]
        }
        return dictionary
    }
    
    // To sort the modified dates dictionary into selectable and removable dates components to future display on calendar.
    private func sortModifiedDateComponents() -> (selectable: Dictionary<DateComponents, [String]>, removable: Dictionary<DateComponents, [String]>) {
        var selectableDateComponents = Dictionary<DateComponents, [String]>()
        var removableDateComponents = Dictionary<DateComponents, [String]>()
        
        for (date, hours) in calendarPlanning.weeklyModifiedDates! {
            if !hours.isEmpty {
                selectableDateComponents[date.mapToWeekdayDateComponents()] = hours
            } else {
                removableDateComponents[date.mapToWeekdayDateComponents()] = hours
            }
        }
        return (selectable: selectableDateComponents, removable: removableDateComponents)
    }
    
    private func getBookedDateComponents() -> Dictionary<DateComponents, [String]> {
        guard let bookedDates = calendarPlanning.bookedDates else {
            return Dictionary<DateComponents, [String]>()
        }
        
        var dictionary = Dictionary<DateComponents, [String]>()
        for (date, hours) in bookedDates {
            dictionary[date.mapToWeekdayDateComponents()] = hours
        }
        return dictionary
    }
    
    private func populateDailyCalendar(with date: Date) -> Bool {
        guard let dailyPlanning = calendarPlanning.dailyPlanning else {
            return false
        }
        
        var dictionary = Dictionary<DateComponents, [String]>()
        for (date, hours) in dailyPlanning {
            dictionary[date.mapToDailyDateComponents()] = hours
        }
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        return dictionary[dateComponents] != nil ? true : false
    }
}
