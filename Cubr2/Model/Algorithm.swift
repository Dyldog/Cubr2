//
//  Algorithm.swift
//  Cubr2
//
//  Created by Dylan Elliott on 14/6/2025.
//

import UIKit

struct AlgorithmGroup: Equatable, Hashable {
    let name: String
    let description: String?
    let algorithms: [Algorithm]
}


struct Algorithm: Equatable, Hashable, Identifiable {
    let name: String
    let description: String?
    let stepSets: [String]
    let scrambles: [Scramble]
    
    var id: Int { hashValue }
    
    var image: UIImage { .init(named: name)! }
    
    var defaultStepsString: String { stepSets.first ?? "NO STEPS!" }
    var defaultSteps: [String] { defaultStepsString.components(separatedBy: " ") }
}
