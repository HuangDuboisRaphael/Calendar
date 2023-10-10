//
//  BookedDate.swift
//  Calendar
//
//  Created by Raphaël Huang-Dubois on 09/10/2023.
//

import Foundation

struct BookedArtSession: Decodable {
    let date: String
    let hour: String
    let duration: Double
    let pricing: Double
    let privateNote: String?
}
