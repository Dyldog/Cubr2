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
        algorithm: AlgorithmWithMethod,
        handler: AlgorithmHandling,
        disallowMmnemonicsUpdating: Bool = false,
        iconTapped: (() -> Void)?
    ) where InnerContent == AlgorithmStepsView {
        self.init(
            algorithm: algorithm,
            bestTime: handler.bestTime(for: algorithm),
            mnemonics: { [weak handler] steps in
                handler?.mnemonics(for: steps) ?? []
            }, iconTapped: {
                iconTapped?()
            }, mnemonicsUpdated: disallowMmnemonicsUpdating ? nil : { [weak handler] newMnemonics, steps in
                handler?.mnemonicsUpdated(newMnemonics, for: steps)
            }
        )

    }
}
