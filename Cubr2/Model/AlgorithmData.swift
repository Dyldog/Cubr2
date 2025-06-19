//
//  AlgorithmData.swift
//  Cubr2
//
//  Created by Dylan Elliott on 14/6/2025.
//

import Foundation

struct AlgorithmGroupData: Codable {
    let algorithms: [AlgorithmData]
    let description: String?
    let groupDescriptions: [String: String]?
    let scrambles: [[String]]
}

extension AlgorithmGroupData {
    var safeScrambles: [[String]] {
        scrambles.isEmpty ? Array(repeating: [], count: algorithms.count) : scrambles
    }
}

struct AlgorithmData: Codable {
    let name: String
    let description: String?
    let alg: [String]
    let group: String
}
