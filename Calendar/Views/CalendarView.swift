//
//  CalendarView.swift
//  Calendar
//
//  Created by Raphaël Huang-Dubois on 02/10/2023.
//

import SwiftUI

// MARK: - Root
struct RootView: View {
    @StateObject private var viewModel = CalendarViewModel()

    var body: some View {
        NavigationStack {
            if viewModel.canLoadCalendar {
                VStack {
                    CalendarView(viewModel: viewModel)
                        .equatable()
                }.frame(maxWidth: .infinity)
                .padding(24)
                .navigationTitle("Calendar")
                Spacer()
            }
        }
    }
}

// MARK: - Calendar
struct CalendarView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        WeekDayHeaderView(viewModel: viewModel)
        Divider()
        CalendarDaysView(viewModel: viewModel)
    }
}

extension CalendarView: Equatable {
    public static func == (lhs: CalendarView, rhs: CalendarView) -> Bool {
        lhs.viewModel.calendar == rhs.viewModel.calendar && lhs.viewModel.startOfMonth == rhs.viewModel.startOfMonth
    }
}

// MARK: - Header
struct WeekDayHeaderView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(), count: viewModel.daysInWeek)) {
            ForEach(viewModel.makeDays.prefix(viewModel.daysInWeek), id: \.self) { date in
                Text(date.mapToString(.weekday))
                    .foregroundColor(.yellow)
                    .font(.system(size: 16, weight: .semibold))
            }
        }.padding(.bottom, 4)
    }
}

// MARK: - Calendar grid
struct CalendarDaysView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(), count: viewModel.daysInWeek)) {
            Section(header: SectionHeaderView(viewModel: viewModel)) {
                SectionContentView(viewModel: viewModel)
            }
        }
    }
}


// MARK: - Section
// Section header composed of current month/year and previous/next month buttons.
struct SectionHeaderView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View{
        HStack {
            Text(viewModel.startOfMonth.mapToString(.month))
                .font(.headline)
                .padding()
            Spacer()
            SectionHeaderButton(
                viewModel: viewModel,
                value: -1,
                dateToCompare: viewModel.startDate,
                comparisonResult: .orderedDescending,
                titleLabel: "Previous",
                titleIconLabel: "chevron.left"
            )
            
            SectionHeaderButton(
                viewModel: viewModel,
                value: 1,
                dateToCompare: viewModel.calendarEndDate,
                comparisonResult: .orderedAscending,
                titleLabel: "Next",
                titleIconLabel: "chevron.right"
            )
        }.padding(.bottom, 6)
    }
}

struct SectionHeaderButton: View {
    @ObservedObject var viewModel: CalendarViewModel
    let value: Int
    let dateToCompare: Date
    let comparisonResult: ComparisonResult
    let titleLabel: String
    let titleIconLabel: String
    
    var body: some View {
        Button {
            viewModel.determineNewStartOfMonth(byAdding: value, comparing: dateToCompare, comparison: comparisonResult)
        } label: {
            Label(
                title: { Text(titleLabel) },
                icon: { Image(systemName: titleIconLabel) }
            )
            .labelStyle(IconOnlyLabelStyle())
            .foregroundColor(.black)
            .opacity(viewModel.isOnCalendarEdges(comparing: dateToCompare, trueValue: 0.2, falseValue: 1))
            .padding(.horizontal)
            .frame(maxHeight: .infinity)
        }.disabled(viewModel.isOnCalendarEdges(comparing: dateToCompare, trueValue: true, falseValue: false))
    }
}

// Section content view displaying all current month days with related UI.
struct SectionContentView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        ForEach(viewModel.makeDays, id: \.self) { date in
            if viewModel.calendar.isDate(date, equalTo: viewModel.startOfMonth, toGranularity: .month) {
                if viewModel.calendar.compare(viewModel.startDate, to: date, toGranularity: .day) == .orderedDescending || viewModel.calendar.compare(viewModel.endDate, to: date, toGranularity: .day) == .orderedAscending {
                    Text("00")
                        .padding(9)
                        .foregroundColor(.clear)
                        .overlay(
                            Text(date.mapToString(.day))
                                .strikethrough(true, color: .black)
                                .opacity(0.3)
                        )
//                } else if viewModel.calendar.component(.weekday, from: date) == 2 {
//                    Button {
//                        withAnimation(.easeInOut(duration: 0.1)) {
//                            viewModel.selectedDate = viewModel.selectedDate == date ? nil : date
//                        }
//                    } label: {
//                        Text("00")
//                            .padding(6)
//                            .foregroundColor(.clear)
//                            .background(
//                                viewModel.selectedDate == date ? .yellow : .blue
//                            )
//                            .cornerRadius(8)
//                            .overlay(
//                                Text(date.mapToString(.day))
//                                    .foregroundColor(.black)
//                            )
//                    }
                } else {
                    Button {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            viewModel.selectedDate = viewModel.selectedDate == date ? nil : date
                        }
                    } label: {
                        Text("00")
                            .padding(9)
                            .foregroundColor(.clear)
                            .background(
                                viewModel.selectedDate == date ? .yellow : .clear
                            )
                            .cornerRadius(8)
                            .overlay(
                                Text(date.mapToString(.day))
                                    .foregroundColor(.black)
                            )
                    }
                }
            } else {
                Text("00")
                    .foregroundColor(.clear)
            }
        }
    }
}

// MARK: - Helpers
private extension Date {
    enum DateFormatType {
        case day
        case weekday
        case month
    }
    
    func mapToString(_ type: DateFormatType) -> String {
        switch type {
        case .day:
            return DateFormatter(dateFormat: "d").string(from: self)
        case .weekday:
            return DateFormatter(dateFormat: "EEEEE").string(from: self)
        case .month:
            return DateFormatter(dateFormat: "MMMM yyyy").string(from: self)
        }
    }
}

private extension DateFormatter {
    convenience init(dateFormat: String) {
        self.init()
        self.dateFormat = dateFormat
    }
}
