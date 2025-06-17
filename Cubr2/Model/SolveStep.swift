//
//  SolveStep.swift
//  Cubr2
//
//  Created by Dylan Elliott on 14/6/2025.
//

import Foundation

enum SolveStep: CaseIterable, Hashable {
    case twoLookOLL
    case twoLookPLL
    
    var file: String {
        switch self {
        case .twoLookPLL: "2LookPLL"
        case .twoLookOLL: "2LookOLL"
        }
    }
    
    var shortTitle: String {
        switch self {
        case .twoLookPLL: "PLL"
        case .twoLookOLL: "OLL"
        }
    }
    
    var title: String {
        switch self {
        case .twoLookPLL: "2-Look PLL"
        case .twoLookOLL: "2-Look OLL"
        }
    }
}

extension SolveStep {
    static func allAlgorithms(with manager: AlgorithmsManager = .shared) -> [(String, [Algorithm])] {
        SolveStep.allCases.flatMap { step in
            manager.algorithms(for: step).map { group in
                ("\(step.shortTitle): \(group.name)", group.algorithms)
            }
        }
    }
}
