//
//  CalendarView.swift
//  Calendar
//
//  Created by Raphaël Huang-Dubois on 22/09/2023.
//

import SwiftUI

struct CalendarView: UIViewRepresentable {
    
    @ObservedObject var viewModel: CalendarPlanningViewModel
    
    // Representable
    typealias UIViewType = UICalendarView
    
    func makeUIView(context: Context) -> UICalendarView {
        let view = UICalendarView()
        view.tintColor = .systemCyan
        view.availableDateRange = DateInterval(start: viewModel.calendarStartingDate, end: viewModel.calendarEndingDate)
        view.timeZone = TimeZone.current
        view.delegate = context.coordinator
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        view.calendar = calendar
        
        let dateSelection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        view.selectionBehavior = dateSelection
        
        return view
    }
    
    func updateUIView(_ uiView: UICalendarView, context: Context) {
    
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    // Coordinator
    class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        
        var parent: CalendarView
        
        init(parent: CalendarView) {
            self.parent = parent
        }
                
        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            guard let dateComponents = dateComponents, let date = dateComponents.date else {
                return
            }
            parent.viewModel.areHoursDisplayed = true
            let correspondingDateComponents = Calendar.current.dateComponents([.year, .month, .day, .weekday], from: date)
            print(parent.viewModel.selectableDates[correspondingDateComponents])
        }
        
        func dateSelection(_ selection: UICalendarSelectionSingleDate, canSelectDate dateComponents: DateComponents?) -> Bool {
            parent.viewModel.populateCalendar(given: dateComponents)
        }
    }
}
