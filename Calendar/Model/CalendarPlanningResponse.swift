//
//  CalendarPlanningResponse.swift
//  Calendar
//
//  Created by Raphaël Huang-Dubois on 29/09/2023.
//

import Foundation

struct CalendarPlanningResponse: Decodable {
    var planningOption: Int
    var weeklyPlanning: Dictionary<Int, [String]>?
    var weeklyStartDate: String?
    var weeklyEndDate: String?
    var weeklyModifiedDates: Dictionary<String, [String]>?
    var dailyPlanning: Dictionary<String, [String]>?
    var bookedDates: Dictionary<String, [String]>?
    var durationSession: Double
}

extension CalendarPlanningResponse {
    func mapToCalendarPlanning() -> CalendarPlanning {
        var calendarPlanning = CalendarPlanning.init(planningOption: .weekly, durationSession: 0.0)
        calendarPlanning.planningOption = self.planningOption == 1 ? .weekly : .daily
        calendarPlanning.weeklyPlanning = self.weeklyPlanning
        calendarPlanning.weeklyStartDate = self.weeklyStartDate
        calendarPlanning.weeklyEndDate = self.weeklyEndDate
        calendarPlanning.weeklyModifiedDates = self.weeklyModifiedDates
        calendarPlanning.dailyPlanning = self.dailyPlanning
        calendarPlanning.bookedDates = self.bookedDates
        calendarPlanning.durationSession = self.durationSession
        return calendarPlanning
    }
}
