//
//  MnemonicsHandling.swift
//  Cubr2
//
//  Created by Dylan Elliott on 14/6/2025.
//

import Foundation

protocol MnemonicsHandling: AnyObject {
    var algorithmsManager: AlgorithmsManager { get }
    func reload()
}

extension MnemonicsHandling {
    func mnemonics(for steps: String) -> [StepMnemonic] {
        algorithmsManager.mnemonics(for: steps)
    }
    
    func mnemonicsUpdated(_ mnemonics: [StepMnemonic], for steps: String) {
        algorithmsManager.updateMnemonics(mnemonics, for: steps)
        reload()
    }
}

extension AlgorithmView {
    init(algorithm: Algorithm, mnemonicsHandler: MnemonicsHandling, iconTapped: @escaping () -> Void) {
        self.init(algorithm: algorithm) { [weak mnemonicsHandler] steps in
            mnemonicsHandler?.mnemonics(for: steps) ?? []
        } iconTapped: {
            iconTapped()
        } mnemonicsUpdated: { [weak mnemonicsHandler] newMnemonics, steps in
            mnemonicsHandler?.mnemonicsUpdated(newMnemonics, for: steps)
        }

    }
}
