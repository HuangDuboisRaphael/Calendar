//
//  CalendarView.swift
//  Calendar
//
//  Created by Raphaël Huang-Dubois on 08/10/2023.
//

import SwiftUI

// MARK: - Calendar
struct CalendarView<Content>: View where Content: View {
    @ObservedObject var viewModel: CalendarViewModel
    let content: (Date, Date) -> Content
    
    init(viewModel: CalendarViewModel, @ViewBuilder content: @escaping (Date, Date) -> Content) {
        self.viewModel = viewModel
        self.content = content
    }
    
    var body: some View {
        WeekDayHeaderView(viewModel: viewModel)
        Divider()
        CalendarScrollView(viewModel: viewModel, content: content)
    }
}

// MARK: - Weekday header
struct WeekDayHeaderView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(), count: CalendarViewModel.daysInWeek)) {
            ForEach(viewModel.firstSevenDaysOfTheMonth, id: \.self) { date in
                Text(date.mapToString(.weekday))
                    .foregroundColor(.yellow)
                    .font(.system(size: 16, weight: .semibold))
            }
        }.padding(.bottom, 4)
    }
}

// MARK: - Calendar scroll view
struct CalendarScrollView<Content>: View where Content: View {
    @ObservedObject var viewModel: CalendarViewModel
    let content: (Date, Date) -> Content
    
    init(viewModel: CalendarViewModel, @ViewBuilder content: @escaping (Date, Date) -> Content) {
        self.viewModel = viewModel
        self.content = content
    }
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                ForEach(viewModel.calendarMonths, id: \.self) { month in
                    VStack(spacing: 2) {
                        Section(
                            header:
                                HStack {
                                    Text(month.mapToString(.month))
                                        .font(.headline)
                                        .padding()
                                    Spacer()
                                },
                            content: {
                                LazyVGrid(columns: Array(repeating: GridItem(), count: CalendarViewModel.daysInWeek)) {
                                    ForEach(viewModel.makeDays(for: month), id: \.self) { date in
                                        content(month, date)
                                    }
                                }
                            })
                    }.padding(.bottom, 10)
                }
            }
        }
    }
}
