//
//  AlgorithmGroupData.swift
//  Cubr2
//
//  Created by Dylan Elliott on 24/6/2025.
//

import Foundation

struct AlgorithmGroupData: Codable {
    let algorithms: [AlgorithmData]
    let description: String?
    let groupDescriptions: [String: String]?
    let scrambles: [[ScrambleData]]
}

extension AlgorithmGroupData {
    var safeScrambles: [[ScrambleData]] {
        scrambles.isEmpty ? Array(repeating: [], count: algorithms.count) : scrambles
    }
}
