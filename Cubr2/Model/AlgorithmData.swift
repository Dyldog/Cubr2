//
//  AlgorithmData.swift
//  Cubr2
//
//  Created by Dylan Elliott on 14/6/2025.
//

import Foundation

typealias ScrambleData = String
typealias GroupScrambleData = [ScrambleData]

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

struct AlgorithmData: Codable {
    let name: String
    let description: String?
    let alg: [String]
    let group: String
}
