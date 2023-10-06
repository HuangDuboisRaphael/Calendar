//
//  CalendarViewModel.swift
//  Calendar
//
//  Created by Raphaël Huang-Dubois on 03/10/2023.
//

import SwiftUI
import Combine

// MARK: - Component
final class CalendarViewModel: ObservableObject {
    // Published properties
    @Published var calendarPlanning: CalendarPlanning?
    @Published var startDate = Date()
    @Published var endDate = Date()
    @Published var startOfMonth = Date()
    @Published var selectedDate: Date?
    @Published var canLoadCalendar = false
       
    // Stored properties
    let calendar = Calendar.current
    let daysInWeek = 7
    private var cancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    private let service: CalendarPlanningService
    
    // Computed properties
    var calendarEndDate: Date {
        calendar.date(byAdding: .year, value: 2, to: startDate) ?? .distantFuture
    }
    
    var makeDays: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: startOfMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1)
        else {
            return []
        }
        let dateInterval = DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end)
        return calendar.generateDays(for: dateInterval)
    }
    
    // Initialization
    init(service: CalendarPlanningService = CalendarPlanningService(type: .weekly)) {
        self.service = service
        addSubscribers()
    }
    
    // Subscribers methods
    private func addSubscribers() {
        addSingleSubscriptionSubscriber()
        addAutoRefreshSubscriber()
    }
    
    private func addSingleSubscriptionSubscriber() {
        cancellable = service.$calendarPlanning
            .dropFirst()
            .sink { [weak self] calendarPlanning in
                guard let self = self else { return }
                self.calendarPlanning = calendarPlanning
                switch calendarPlanning.planningOption {
                case .weekly:
                    self.startDate = calendarPlanning.weeklyStartDate == nil ? Date() : calendarPlanning.weeklyStartDate!.mapToDate()
                    self.startOfMonth = startDate.startOfMonth(using: calendar)
                    self.endDate = calendarPlanning.weeklyEndDate == nil ? calendarEndDate : calendarPlanning.weeklyEndDate!.mapToDate()
                case .daily:
                    self.startDate = calendarPlanning.dailyPlanning.determineCalendarDates().start
                    self.startOfMonth = startDate.startOfMonth(using: calendar)
                    self.endDate = calendarPlanning.dailyPlanning.determineCalendarDates().end
                }
                self.canLoadCalendar = true
                self.cancellable?.cancel()
            }
    }
    
    private func addAutoRefreshSubscriber() {
        service.$calendarPlanning
            .dropFirst(2)
            .sink { [weak self] calendarPlanning in
//                guard let self = self else { return }
//                self.calendarPlanning = calendarPlanning
//                switch calendarPlanning.planningOption {
//                case .weekly:
//                    self.startDate = calendarPlanning.weeklyStartDate == nil ? Date() : calendarPlanning.weeklyStartDate!.mapToDate()
//                    self.startOfMonth = startDate.startOfMonth(using: calendar)
//                    self.endDate = calendarPlanning.weeklyEndDate == nil ?
//                    self.calendar.date(byAdding: .year, value: 2, to: Date()) ?? Date() : calendarPlanning.weeklyEndDate!.mapToDate()
//                case .daily:
//                    self.startDate = calendarPlanning.dailyPlanning.determineCalendarDates().start
//                    self.startOfMonth = startDate.startOfMonth(using: calendar)
//                    self.endDate = calendarPlanning.dailyPlanning.determineCalendarDates().end
//                }
            }.store(in: &cancellables)
    }
    
    // Logic methods
    func determineNewStartOfMonth(byAdding value: Int, comparing date: Date, comparison: ComparisonResult) {
        guard let newDate = calendar.date(
            byAdding: .month,
            value: value,
            to: startOfMonth
        ) else {
            return
        }
        if calendar.compare(date, to: newDate, toGranularity: .month) != comparison {
            startOfMonth = newDate
        }
    }
    
    func isOnCalendarEdges<T>(comparing date: Date, trueValue: T, falseValue: T) -> T {
        calendar.compare(date, to: startOfMonth, toGranularity: .month) == .orderedSame ? trueValue : falseValue
    }
}

// MARK: - Helpers
private extension Date {
    func startOfMonth(using calendar: Calendar) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month, .day], from: self)) ?? self
    }
}

private extension Calendar {
    func generateDays(for dateInterval: DateInterval) -> [Date] {
        generateDates(
            for: dateInterval,
            matching: dateComponents([.hour, .minute, .second], from: dateInterval.start)
        )
    }
    
    func generateDates(for dateInterval: DateInterval, matching components: DateComponents) -> [Date] {
        var dates = [dateInterval.start]

        enumerateDates(
            startingAfter: dateInterval.start,
            matching: components,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            guard let date = date else { return }

            guard date < dateInterval.end else {
                stop = true
                return
            }
            dates.append(date)
        }
        return dates
    }
}

private extension Dictionary<String, [String]>? {
    func determineCalendarDates() -> DateInterval {
        guard let self = self else {
            return DateInterval(start: Date(), end: Date())
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"

        var dates: [Date] = []
        for date in self.keys {
            if let date = dateFormatter.date(from: date) {
                dates.append(date)
            }
        }
        guard let startDate = dates.min(), let endDate = dates.max() else {
            return DateInterval(start: Date(), end: Date())
        }
        return DateInterval(start: startDate, end: endDate)
    }
}
