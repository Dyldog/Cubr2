//
//  AlgorithmHandling.swift
//  Cubr2
//
//  Created by Dylan Elliott on 17/6/2025.
//

import Foundation

protocol AlgorithmHandling: MnemonicsHandling, BestTimeHandling { }

extension AlgorithmView {
    init(
        algorithm: Algorithm,
        handler: AlgorithmHandling,
        iconTapped: @escaping () -> Void
    ) {
        self.init(algorithm: algorithm, bestTime: handler.bestTime(for: algorithm)) { [weak handler] steps in
            handler?.mnemonics(for: steps) ?? []
        } iconTapped: {
            iconTapped()
        } mnemonicsUpdated: { [weak handler] newMnemonics, steps in
            handler?.mnemonicsUpdated(newMnemonics, for: steps)
        }

    }
}
