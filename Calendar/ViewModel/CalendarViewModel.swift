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
    @Published var bookedPerformances: [BookedPerformance] = []
    @Published var bookedDates: [Date] = []
    @Published var selectedDate: Date?
    @Published var canLoadCalendar = false
       
    let calendar = Calendar.current
    static let daysInWeek = 7
    private var cancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    private let service: CalendarPlanningService
    
    init(service: CalendarPlanningService = CalendarPlanningService()) {
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
        cancellable = service.$bookedPerformances
            .dropFirst()
            .sink { [weak self] performances in
                guard let self = self else { return }
                self.bookedPerformances = performances
                self.bookedDates = bookedPerformances.map { $0.date.mapToDate() }
                self.canLoadCalendar = true
                self.cancellable?.cancel()
            }
    }
    
    func addAutoRefreshSubscriber() {
        service.$bookedPerformances
            .dropFirst(2)
            .sink { bookedDates in }.store(in: &cancellables)
    }
}

// MARK: - Calendar related computed properties/logic methods
extension CalendarViewModel {
    
    var startingDate: Date {
        guard let startingDate = bookedDates.min() else {
            return Date()
        }
        return startingDate
    }
    
    var startingMonth: Date {
        startingDate.startOfMonth(using: calendar)
    }
    
    var calendarEndDate: Date {
        calendar.date(byAdding: .year, value: 2, to: startingDate) ?? .distantFuture
    }
    
    var calendarMonths: [Date] {
        guard let lastMonth = calendar.date(byAdding: .year, value: 1, to: startingMonth) else {
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
