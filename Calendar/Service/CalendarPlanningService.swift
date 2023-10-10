//
//  AsyncAwaitCalendarPlanningService.swift
//  Calendar
//
//  Created by Raphaël Huang-Dubois on 10/10/2023.
//

import Foundation

protocol CalendarPlanningServiceRepresentable {
    func fetchBookedArtSession() async throws -> [BookedArtSession]
}

final class CalendarPlanningService: CalendarPlanningServiceRepresentable {
    private var url: URL {
        Bundle.main.url(forResource: "BookedArtSession", withExtension: "json")!
    }
    
    func fetchBookedArtSession() async throws -> [BookedArtSession] {
        let (data, _) = try await URLSession.shared.data(from: url)
        let bookedArtSession = try? JSONDecoder().decode([BookedArtSession].self, from: data)
        
        return bookedArtSession ?? []
    }
}
