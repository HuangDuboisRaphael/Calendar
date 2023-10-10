//
//  CalendarViewModel.swift
//  Calendar
//
//  Created by Raphaël Huang-Dubois on 03/10/2023.
//

import SwiftUI

// MARK: - Protocol to conform
@MainActor
protocol UserCalendarViewModelRepresentable: ObservableObject, LoadableObject {
    var task: Task<Void, Never>? { get }
    var bookedArtSession: [BookedArtSession] { get }
    var bookedDates: [Date] { get }
    var selectedDate: Date? { get set }
    var calendar: Calendar { get }
    var daysInWeek: Int { get }
    var startingDate: Date { get }
    var startingMonth: Date { get }
    var calendarEndDate: Date { get }
    var calendarMonths: [Date] { get }
    var firstSevenDaysOfTheMonth: ArraySlice<Date> { get }
    
    func makeDays(for month: Date) -> [Date]
}

// MARK: - Main component conforming to protocol
@MainActor
final class UserCalendarViewModel: UserCalendarViewModelRepresentable {
    //Protocol published properties
    @Published var state: LoadingState = .idle
    @Published private(set) var task: Task<Void, Never>?
    @Published private(set) var bookedArtSession: [BookedArtSession] = []
    @Published private(set) var bookedDates: [Date] = []
    @Published var selectedDate: Date?
    
    // Protocol computed properties
    var calendar: Calendar { Calendar.current }
    var daysInWeek: Int { 7 }
    var startingDate: Date {
        guard let startingDate = bookedDates.min() else {
            return Date()
        }
        return startingDate
    }
    var startingMonth: Date { startingDate.startOfMonth(using: calendar) }
    var calendarEndDate: Date { calendar.date(byAdding: .year, value: 2, to: startingDate) ?? .distantFuture }
    var calendarMonths: [Date] {
        guard let lastMonth = calendar.date(byAdding: .year, value: 1, to: startingMonth) else {
            return []
        }
        let dateInterval = DateInterval(start: startingMonth, end: lastMonth)
        return calendar.generateDates(for: dateInterval, type: .month)
    }
    var firstSevenDaysOfTheMonth: ArraySlice<Date> { daysForStartingMonth.prefix(daysInWeek) }
    
    // Private properties
    private let service: CalendarPlanningServiceRepresentable
    
    // Initialization
    init(service: CalendarPlanningServiceRepresentable = CalendarPlanningService()) {
        self.service = service
    }
    
    // Protocol methods
    func makeDays(for month: Date) -> [Date] {
        calendar.generateDates(for: determineDateInterval(for: month), type: .day)
    }
    
    func makeRequest() {
        if bookedArtSession.isEmpty {
            state = .loading
        }
        task = Task {
            async let request = await service.fetchBookedArtSession()
            do {
                bookedArtSession = try await request
                bookedDates = bookedArtSession.map({ $0.date.mapToDate() })
                state = .loaded
                
                try await Task.sleep(for: .seconds(5))
                guard !Task.isCancelled else { return }
                makeRequest()
            } catch {
                state = .failed(error)
                print(error)
            }
        }
    }
}

// MARK: - Private computed properties/logic methods
private extension UserCalendarViewModel {
    var daysForStartingMonth: [Date] {
        calendar.generateDates(for: determineDateInterval(for: startingMonth), type: .day)
    }
    
    func determineDateInterval(for month: Date) -> DateInterval {
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

private extension String {
    func mapToDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        guard let date = dateFormatter.date(from: self) else {
            return Date()
        }
        return date
    }
}
