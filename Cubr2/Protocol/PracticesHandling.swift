//
//  PracticesHandling.swift
//  Cubr2
//
//  Created by Dylan Elliott on 24/6/2025.
//

import SwiftUI

protocol PracticesHandling: AnyObject {
    typealias Label = (Int, Color, Image)

    var algorithmsManager: AlgorithmsManager { get }
}

extension PracticesHandling {
    func labels(for algorithm: Algorithm, on day: Day) -> [Label] {
        algorithmsManager.learningEvents(for: algorithm, on: day)
            .uniqueCount
            .sorted { $0.key < $1.key }
            .map { ($0.value, $0.key.color, $0.key.image) }
    }
    
    private func algorithms(for day: Day) -> [AlgorithmWithMethod] {
        algorithmsManager.methodsEnabled
            .algorithms(with: algorithmsManager) { _ in true }
            .algorithmsWithMethod
    }
    
    func labels(for day: Day) -> [(AlgorithmWithMethod, [Label])] {
        algorithms(for: day).map { algorithm in
            (algorithm, labels(for: algorithm.algorithm, on: day))
        }
        .filter { $0.1.isEmpty == false }
    }
}
