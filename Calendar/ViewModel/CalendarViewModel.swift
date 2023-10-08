//
//  CalendarViewModel.swift
//  Calendar
//
//  Created by Raphaël Huang-Dubois on 03/10/2023.
//

import SwiftUI
import Combine

// MARK: - Stored properties and initialization
@MainActor
final class CalendarViewModel: ObservableObject {
    @Published var calendarPlanning: CalendarPlanning?
    @Published var startingDay = Date()
    @Published var endingDay = Date()
    @Published var startingMonth = Date()
    @Published var selectedDate: Date?
    @Published var canLoadCalendar = false
       
    let calendar = Calendar.current
    static let daysInWeek = 7
    private var cancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    private let service: CalendarPlanningService
    
    init(service: CalendarPlanningService = CalendarPlanningService(type: .weekly)) {
        self.service = service
        addSubscribers()
    }
}

// MARK: - Subcribers methods
private extension CalendarViewModel {
    func addSubscribers() {
        addSingleSubscriptionSubscriber()
        addAutoRefreshSubscriber()
    }
    
    func addSingleSubscriptionSubscriber() {
        cancellable = service.$calendarPlanning
            .dropFirst()
            .sink { [weak self] calendarPlanning in
                guard let self = self else { return }
                self.calendarPlanning = calendarPlanning
                switch calendarPlanning.planningOption {
                case .weekly:
                    self.startingDay = calendarPlanning.weeklyStartDate == nil ? Date() : calendarPlanning.weeklyStartDate!.mapToDate()
                    self.startingMonth = startingDay.startOfMonth(using: calendar)
                    self.endingDay = calendarPlanning.weeklyEndDate == nil ? calendarEndDate : calendarPlanning.weeklyEndDate!.mapToDate()
                case .daily:
                    self.startingDay = calendarPlanning.dailyPlanning.determineCalendarDates().start
                    self.startingMonth = startingDay.startOfMonth(using: calendar)
                    self.endingDay = calendarPlanning.dailyPlanning.determineCalendarDates().end
                }
                self.canLoadCalendar = true
                self.cancellable?.cancel()
            }
    }
    
    func addAutoRefreshSubscriber() {
        service.$calendarPlanning
            .dropFirst(2)
            .sink { calendarPlanning in }.store(in: &cancellables)
    }
}

// MARK: - Calendar related computed properties/logic methods
extension CalendarViewModel {
    
    var calendarEndDate: Date {
        calendar.date(byAdding: .year, value: 2, to: startingDay) ?? .distantFuture
    }
    
    var calendarMonths: [Date] {
        guard let lastMonth = calendar.date(byAdding: .year, value: 2, to: startingMonth) else {
            return []
        }
        let dateInterval = DateInterval(start: startingMonth, end: lastMonth)
        return calendar.generateDates(for: dateInterval, type: .month)
    }
    
    var firstSevenDaysOfTheMonth: ArraySlice<Date> {
        daysForStartingMonth.prefix(CalendarViewModel.daysInWeek)
    }
    
    private var daysForStartingMonth: [Date] {
        calendar.generateDates(for: determineDateInterval(for: startingMonth), type: .day)
    }
    
    func makeDays(for month: Date) -> [Date] {
        calendar.generateDates(for: determineDateInterval(for: month), type: .day)
    }
    
    private func determineDateInterval(for month: Date) -> DateInterval {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1)
        else {
            return DateInterval()
        }
        return DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end)
    }
    
    func isOnCalendarEdges<T>(comparing date: Date, trueValue: T, falseValue: T) -> T {
        calendar.compare(date, to: startingMonth, toGranularity: .month) == .orderedSame ? trueValue : falseValue
    }
}

// MARK: - Helpers
private extension Date {
    func startOfMonth(using calendar: Calendar) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month, .day], from: self)) ?? self
    }
}

private extension Calendar {
    enum DateComponentsType {
        case month
        case day
    }
    
    func generateDates(for dateInterval: DateInterval, type: DateComponentsType) -> [Date] {
        switch type {
        case .month:
            return generateDates(
                for: dateInterval,
                matching: dateComponents([.day], from: dateInterval.start)
            )
        case .day:
            return generateDates(
                for: dateInterval,
                matching: dateComponents([.hour, .minute, .second], from: dateInterval.start)
            )
        }
    }
    
    private func generateDates(for dateInterval: DateInterval, matching components: DateComponents) -> [Date] {
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
