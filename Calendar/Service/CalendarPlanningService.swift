//
//  CalendarPlanningService.swift
//  Calendar
//
//  Created by Raphaël Huang-Dubois on 29/09/2023.
//

import SwiftUI
import Combine

final class CalendarPlanningService {
    
    @Published var calendarPlanning = CalendarPlanning(planningOption: .weekly, durationSession: 0.0)
    
    private let type: CalendarPlanning.PlanningType
    private let forResource: String
    private let refreshInterval: TimeInterval = 5.0
    private var cancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    
    init(type: CalendarPlanning.PlanningType) {
        self.type = type
        forResource = type == .weekly ? "CalendarPlanningWeekly" : "CalendarPlanningDaily"
        addSubcribers()
    }
    
    private func addSubcribers() {
        fetchAndSetCalendarPlanning()
        setupAutoRefeshCalendarPlanning()
    }
    
    private func fetchAndSetCalendarPlanning() {
        cancellable = URLSession.shared.dataTaskPublisher(for: Bundle.main.url(forResource: forResource, withExtension: "json")!)
            .subscribe(on: DispatchQueue.global(qos: .default))
            .map { $0.data }
            .receive(on: DispatchQueue.main)
            .decode(type: CalendarPlanningResponse.self, decoder: JSONDecoder())
            .map { $0.mapToCalendarPlanning() }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case.failure(let error):
                    print(error)
                }
            }, receiveValue: { [weak self] value in
                guard let self = self else { return }
                self.calendarPlanning = value
                self.cancellable?.cancel()
            })
    }
    
    private func setupAutoRefeshCalendarPlanning() {
        Timer
            .publish(every: refreshInterval, on: .main, in: .common)
            .autoconnect()
            .flatMap { [weak self] _ in
                URLSession.shared.dataTaskPublisher(for: Bundle.main.url(forResource: self?.forResource, withExtension: "json")!)
                    .subscribe(on: DispatchQueue.global(qos: .default))
                    .map { $0.data }
                    .receive(on: DispatchQueue.main)
                    .decode(type: CalendarPlanningResponse.self, decoder: JSONDecoder())
                    .map { $0.mapToCalendarPlanning() }
            }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case.failure(let error):
                    print(error)
                }
            }, receiveValue: { [weak self] value in
                self?.calendarPlanning = value
            }).store(in: &cancellables)
    }
}
