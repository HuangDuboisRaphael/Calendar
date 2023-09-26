//
//  Event.swift
//  Calendar
//
//  Created by Raphaël Huang-Dubois on 25/09/2023.
//

import SwiftUI

struct CalendarPlanning {
    var weeklyPlanning: Dictionary<Int, [String]>?
    var weeklyModifiedDates: Dictionary<String, [String]>?
    var dailyPlanning: Dictionary<String, [String]>?
    var duration: Double
    
    static var weeklyExample: CalendarPlanning {
        CalendarPlanning.init(
            weeklyPlanning: [2: ["14:00 PM", "16:00 PM", "18:00 PM"],
                     3: ["16:00 PM", "18:00 PM"],
                     4: [],
                     5: ["18:00 PM"],
                     6: ["10:00 PM", "18:00 PM"],
                     7: [],
                     1: ["15:00 PM"],
                    ],
            weeklyModifiedDates: ["26/09/2023": ["15:00 PM", "17:00 PM"],
                                  "30/09/2023": ["09:00 AM", "14:00 PM"]
                                 ],
            duration: 120.0)
    }
    
    static var customizeExample: CalendarPlanning {
        CalendarPlanning.init(
            dailyPlanning: ["27/09/2023": ["12:00 PM", "19:00 PM"],
                    "38/09/2023": ["09:00 AM", "10:00 AM", "11:00 AM", "12:00 AM", "13:00 PM", "14:00 PM", "15:00 PM", "16:00 PM"]
                   ],
            duration: 60.0)
    }
}
