//
//  CalendarUserView.swift
//  Calendar
//
//  Created by Raphaël Huang-Dubois on 07/10/2023.
//

import SwiftUI

// MARK: - Root
struct CalendarUserView: View {
    @StateObject private var viewModel = CalendarViewModel(service: CalendarPlanningService())

    var body: some View {
        NavigationStack {
            if viewModel.canLoadCalendar {
                VStack {
                    CalendarView(viewModel: viewModel) { month, date in
                        if viewModel.calendar.isDate(date, equalTo: month, toGranularity: .month) {
                            if !viewModel.bookedDates.contains(date) {
                                Text("00")
                                    .padding(8)
                                    .foregroundColor(.clear)
                                    .overlay(
                                        Text(date.mapToString(.day))
                                            .font(.system(size: 14))
                                            .strikethrough(true, color: .black)
                                            .opacity(0.3)
                                    )
                            } else {
                                Button {
                                    viewModel.selectedDate = viewModel.selectedDate == date ? nil : date
                                } label: {
                                    Text("00")
                                        .padding(8)
                                        .foregroundColor(.clear)
                                        .background(
                                            viewModel.selectedDate == date ? .yellow : .clear
                                        )
                                        .cornerRadius(8)
                                        .overlay(
                                            Text(date.mapToString(.day))
                                                .font(.system(size: 14))
                                                .foregroundColor(.black)
                                        )
                                }.buttonStyle(.plain)
                            }
                        } else {
                            Text("00")
                                .foregroundColor(.clear)
                        }
                    }
                }.frame(maxWidth: .infinity)
                .padding(16)
                .navigationTitle("Calendar")
                Spacer()
            }
        }
    }
}
