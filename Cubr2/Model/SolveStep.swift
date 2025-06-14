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
    
    var title: String {
        switch self {
        case .twoLookPLL: "2-Look PLL"
        case .twoLookOLL: "2-Look OLL"
        }
    }
}
