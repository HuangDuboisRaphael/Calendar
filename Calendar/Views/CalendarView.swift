//
//  CalendarView.swift
//  Calendar
//
//  Created by Raphaël Huang-Dubois on 22/09/2023.
//

import SwiftUI

struct CalendarView: UIViewRepresentable {
    
    @StateObject private var viewModel = CalendarPlanningViewModel()
    
    // Representable
    typealias UIViewType = UICalendarView
    
    func makeUIView(context: Context) -> UICalendarView {
        let view = UICalendarView()
        view.availableDateRange = DateInterval(start: Date(), end: viewModel.twoYearsFromToday)
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

        @MainActor
        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            guard parent.viewModel.canSelectWeekdays(with: dateComponents),
                  parent.viewModel.isFutureDate(given: dateComponents) else {
                return nil
            }
            return UICalendarView.Decoration.customView {
                let view = UILabel()
                view.text = "\(self.parent.viewModel.numberOfAvailabilities(given: dateComponents)) left"
                view.font = UIFont.systemFont(ofSize: 11)
                view.textColor = .lightGray
                return view
            }
        }
                
        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
      
        }
        
        func dateSelection(_ selection: UICalendarSelectionSingleDate, canSelectDate dateComponents: DateComponents?) -> Bool {
            parent.viewModel.canSelectWeekdays(with: dateComponents)
        }
    }
}
