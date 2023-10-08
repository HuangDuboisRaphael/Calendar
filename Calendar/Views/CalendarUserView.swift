//
//  CalendarUserView.swift
//  Calendar
//
//  Created by Raphaël Huang-Dubois on 07/10/2023.
//

import SwiftUI

// MARK: - Root
struct CalendarUserView: View {
    @StateObject private var viewModel = CalendarViewModel()

    var body: some View {
        NavigationStack {
            if viewModel.canLoadCalendar {
                VStack {
                    CalendarView(viewModel: viewModel) { month, date in
                        if viewModel.calendar.isDate(date, equalTo: month, toGranularity: .month) {
                            if viewModel.calendar.compare(viewModel.startingDay, to: date, toGranularity: .day) == .orderedDescending || viewModel.calendar.compare(viewModel.endingDay, to: date, toGranularity: .day) == .orderedAscending {
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
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        DispatchQueue.main.async {
                                            viewModel.selectedDate = viewModel.selectedDate == date ? nil : date
                                        }
                                    }
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
                                }
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
