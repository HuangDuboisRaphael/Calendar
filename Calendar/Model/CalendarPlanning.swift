//
//  Event.swift
//  Calendar
//
//  Created by Raphaël Huang-Dubois on 25/09/2023.
//

import SwiftUI

struct CalendarPlanning {
    enum PlanningOption {
        case weekly
        case daily
    }
    
    var planningOption: CalendarPlanning.PlanningOption
    var weeklyPlanning: Dictionary<Int, [String]>?
    var weeklyStartingDate: String?
    var weeklyEndingDate: String?
    var weeklyModifiedDates: Dictionary<String, [String]>?
    var dailyPlanning: Dictionary<String, [String]>?
    var bookedDates: Dictionary<String, [String]>?
    var durationSession: Double
    
    static var weeklyExample: CalendarPlanning {
        CalendarPlanning.init(
            planningOption: .weekly,
            weeklyPlanning: [2: ["14:00 PM", "16:00 PM", "18:00 PM"],
                     3: ["16:00 PM", "18:00 PM"],
                     4: [],
                     5: ["18:00 PM"],
                     6: ["10:00 PM", "18:00 PM"],
                     7: [],
                     1: ["15:00 PM"],
                    ],
//            weeklyStartingDate: "30/09/2023",
//            weeklyEndingDate: "11/12/2023",
            weeklyModifiedDates: ["25/10/2023": ["15:00 PM", "17:00 PM"],
                                  "30/09/2023": ["09:00 AM", "14:00 PM"],
                                  "08/10/2023": [],
                                  "07/10/2023": ["09:00 AM", "14:00 PM"]
                                 ],
            durationSession: 120.0)
    }
    
    static var dailyExample: CalendarPlanning {
        CalendarPlanning.init(
            planningOption: .daily,
            dailyPlanning: ["27/09/2023": ["12:00 PM", "19:00 PM"],
                            "30/09/2023": ["09:00 AM", "10:00 AM", "11:00 AM", "12:00 AM", "13:00 PM", "14:00 PM", "15:00 PM", "16:00 PM"],
                            "26/09/2023": ["15:00 PM", "17:00 PM"],
                            "30/12/2023": ["09:00 AM", "14:00 PM"],
                            "08/10/2023": ["12:00 AM"]
                   ],
            durationSession: 60.0)
    }
}
