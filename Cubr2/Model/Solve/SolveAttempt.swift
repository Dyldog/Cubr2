//
//  SolveAttempt.swift
//  Cubr2
//
//  Created by Dylan Elliott on 17/6/2025.
//

import Foundation

struct SolveAttempt: Codable, Identifiable, Hashable {
    let id: UUID
    let date: Date
    let time: Duration
    let hints: Int
    let scramble: [String]
}
