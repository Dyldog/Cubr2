//
//  AlgorithmData.swift
//  Cubr2
//
//  Created by Dylan Elliott on 14/6/2025.
//

import Foundation

struct AlgorithmGroupData: Codable {
    let algorithms: [AlgorithmData]
    let scrambles: [[String]]
}

struct AlgorithmData: Codable {
    let name: String
    let alg: [String]
    let group: String
}
