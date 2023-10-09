//
//  CalendarApp.swift
//  Calendar
//
//  Created by Raphaël Huang-Dubois on 22/09/2023.
//

import SwiftUI

@main
struct CalendarApp: App {
    @State private var test = false
    
    var body: some Scene {
        WindowGroup {
            CalendarUserView()
        }
    }
}
