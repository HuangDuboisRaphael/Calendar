//
//  HomeView.swift
//  Calendar
//
//  Created by Raphaël Huang-Dubois on 22/09/2023.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = CalendarPlanningViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                CalendarView(viewModel: viewModel)
                
                if viewModel.areHoursDisplayed {
                    Color.black
                }
                
            }.navigationTitle("Calendar View")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
