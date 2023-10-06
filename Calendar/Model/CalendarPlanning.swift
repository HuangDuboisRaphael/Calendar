//
//  Event.swift
//  Calendar
//
//  Created by Raphaël Huang-Dubois on 25/09/2023.
//

import SwiftUI

struct CalendarPlanning {
    enum PlanningType {
        case weekly
        case daily
    }
    var planningOption: CalendarPlanning.PlanningType
    var weeklyPlanning: Dictionary<Int, [String]>?
    var weeklyStartDate: String?
    var weeklyEndDate: String?
    var weeklyModifiedDates: Dictionary<String, [String]>?
    var dailyPlanning: Dictionary<String, [String]>?
    var bookedDates: Dictionary<String, [String]>?
    var durationSession: Double
}
