//
//  CalendarPlanningService.swift
//  Calendar
//
//  Created by Raphaël Huang-Dubois on 29/09/2023.
//

import SwiftUI
import Combine

final class CalendarPlanningService {
    
    @Published var bookedPerformances: [BookedPerformance] = []
    
    private let refreshInterval: TimeInterval = 5.0
    private var cancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        addSubcribers()
    }
    
    private func addSubcribers() {
        fetchAndSetCalendarPlanning()
        setupAutoRefeshCalendarPlanning()
    }
    
    private func fetchAndSetCalendarPlanning() {
        cancellable = URLSession.shared.dataTaskPublisher(for: Bundle.main.url(forResource: "BookedDates", withExtension: "json")!)
            .subscribe(on: DispatchQueue.global(qos: .default))
            .map { $0.data }
            .receive(on: DispatchQueue.main)
            .decode(type: [BookedPerformance].self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case.failure(let error):
                    print(error)
                }
            }, receiveValue: { [weak self] performances in
                guard let self = self else { return }
                self.bookedPerformances = performances
                self.cancellable?.cancel()
            })
    }
    
    private func setupAutoRefeshCalendarPlanning() {
        Timer
            .publish(every: refreshInterval, on: .main, in: .common)
            .autoconnect()
            .flatMap { _ in
                URLSession.shared.dataTaskPublisher(for: Bundle.main.url(forResource: "BookedDates", withExtension: "json")!)
                    .subscribe(on: DispatchQueue.global(qos: .default))
                    .map { $0.data }
                    .receive(on: DispatchQueue.main)
                    .decode(type: [BookedPerformance].self, decoder: JSONDecoder())
            }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case.failure(let error):
                    print(error)
                }
            }, receiveValue: { [weak self] performances in
                self?.bookedPerformances = performances
            }).store(in: &cancellables)
    }
}
