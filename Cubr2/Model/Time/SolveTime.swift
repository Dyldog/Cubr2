//
//  SolveTime.swift
//  Cubr2
//
//  Created by Dylan Elliott on 24/6/2025.
//

import Foundation

struct SolveTime {
    let time: Duration
    let hints: Int
    
    var string: String { "\(time.timeString) (\(hints))" }
}
