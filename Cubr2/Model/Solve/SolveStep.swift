//
//  SolveStep.swift
//  Cubr2
//
//  Created by Dylan Elliott on 14/6/2025.
//

import Foundation

enum SolveMethod: String, CaseIterable, Codable {
    case beginner = "BEGINNER"
    case cfop = "CFOP"
    
    var title: String {
        switch self {
        case .beginner: "Beginner"
        case .cfop: "CFOP"
        }
    }
    
    var steps: [any SolveStep] {
        switch self {
        case .beginner: BeginnerSolveStep.allCases
        case .cfop: CFOPSolveStep.allCases
        }
    }
}

protocol SolveStep: CaseIterable, Hashable {
    
    var file: String { get }
    
    var title: String { get }
    var shortTitle: String { get }
    
    var description: String? { get }
    
    var method: SolveMethod { get }
    
    var operatesOnFlipped: Bool { get }
}

extension SolveStep {
    var shortTitle: String { title }
    
    var operatesOnFlipped: Bool { true }
}

enum BeginnerSolveStep: SolveStep {
    case firstLayer
    case secondLayer
    case topLayer
    
    var method: SolveMethod { .beginner }
    
    var file: String {
        switch self {
        case .firstLayer: "BeginnerFirstLayer"
        case .secondLayer: "BeginnerSecondLayer"
        case .topLayer: "BeginnerTopLayer"
        }
    }
    
    var title: String {
        switch self {
        case .firstLayer: "First Layer"
        case .secondLayer: "Second Layer"
        case .topLayer: "Top Layer"
        }
    }
    
    var shortTitle: String { title }
    
    var description: String? {
        nil
    }
    
    var operatesOnFlipped: Bool {
        self != .firstLayer
    }
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
    
    var description: String? {
        nil
    }
}
