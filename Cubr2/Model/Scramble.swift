//
//  Scramble.swift
//  Cubr2
//
//  Created by Dylan Elliott on 21/6/2025.
//

import Foundation

typealias ScrambleStep = String
typealias Scramble = [ScrambleStep]

extension ScrambleData {
    var scramble: Scramble { components(separatedBy: " ") }
}

extension [ScrambleData] {
    var scrambles: [Scramble] { map { $0.scramble } }
}
