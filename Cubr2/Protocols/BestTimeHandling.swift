//
//  BestTimeHandling.swift
//  Cubr2
//
//  Created by Dylan Elliott on 17/6/2025.
//

import Foundation

protocol BestTimeHandling {
    var algorithmsManager: AlgorithmsManager { get }
}

extension BestTimeHandling {
    func bestTime(for algorithm: AlgorithmWithMethod) -> Duration? {
        algorithmsManager.bestTime(for: .algorithm(algorithm))
    }
}
