//
//  HomeView.swift
//  Calendar
//
//  Created by Raphaël Huang-Dubois on 22/09/2023.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                CalendarView()
                    .padding(.horizontal, 10)
            }.navigationTitle("Calendar View")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
