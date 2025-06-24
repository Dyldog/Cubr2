//
//  AlgorithmsManaging.swift
//  Cubr2
//
//  Created by Dylan Elliott on 24/6/2025.
//

import Foundation

protocol AlgorithmsManaging {
    func algorithms(for step: any SolveStep) -> [AlgorithmGroup]
}
