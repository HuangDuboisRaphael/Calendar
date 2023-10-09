//
//  BookableDate.swift
//  Calendar
//
//  Created by Raphaël Huang-Dubois on 25/09/2023.
//

import Foundation

struct BookablePerformance: Decodable {
    let date: String
    let hours: [String]
    let duration: Double
    let pricing: Double
    let privateNote: String?
}
