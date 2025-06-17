//
//  SolveStep.swift
//  Cubr2
//
//  Created by Dylan Elliott on 14/6/2025.
//

import Foundation

enum SolveMethod: CaseIterable {
    case cfop
    
    var title: String {
        switch self {
        case .cfop: "CFOP"
        }
    }
    
    var steps: [any SolveStep] {
        switch self {
        case .cfop: CFOPSolveStep.allCases
        }
    }
}

protocol SolveStep: CaseIterable, Hashable {
    
    var file: String { get }
    
    var title: String { get }
    var shortTitle: String { get }
    
    var method: SolveMethod { get }
}

extension SolveStep {
    var shortTitle: String { title }
}

enum CFOPSolveStep: SolveStep {
    case twoLookOLL
    case twoLookPLL
    
    var method: SolveMethod { .cfop }
    
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

extension SolveMethod {
    static func allAlgorithms(with manager: AlgorithmsManager = .shared) -> [(String, [Algorithm])] {
        SolveMethod.allCases.flatMap { method in
            method.steps.flatMap { step in
                manager.algorithms(for: step).map { group in
                    ("\(step.shortTitle): \(group.name)", group.algorithms)
                }
            }
        }
    }
}
