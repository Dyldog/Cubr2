//
//  AlgorithmsManager.swift
//  Cubr2
//
//  Created by Dylan Elliott on 10/6/2025.
//

import DylKit
import UIKit

class AlgorithmsManager: ObservableObject {
    static var shared: AlgorithmsManager = .init()
    
    @UserDefaultable(key: DefaultKeys.learnedAlgorithms)
    private var storedLearningAlgorithms: [String: Bool] = [:]
    
    @UserDefaultable(key: DefaultKeys.mnemonics) 
    private var mnemonics: [String: [StepMnemonic]] = [:]
    
    private func data(for step: SolveStep) -> AlgorithmGroupData {
        let url = Bundle.main.url(forResource: step.file, withExtension: "json")!
        let data = try! Data(contentsOf: url)
        return try! JSONDecoder().decode(AlgorithmGroupData.self, from: data)
    }
    
    func algorithms(for step: SolveStep) -> [AlgorithmGroup] {
        let data = data(for: step)
        
        return data.algorithms.enumerated().reduce(into: [:]) { groups, algorithm in
            groups[algorithm.element.group, default: []].append(
                Algorithm(
                    name: algorithm.element.name,
                    stepSets: algorithm.element.alg,
                    scrambles: data.scrambles[algorithm.offset]
                )
            )
        }.map {
            AlgorithmGroup(name: $0.key, algorithms: $0.value)
        }.sorted {
            $0.name < $1.name
        }
    }
    
    func algorithmIsLearning(_ algorithm: Algorithm) -> Bool {
        storedLearningAlgorithms[algorithm.name] ?? false
    }
    
    func markAlgorithmForLearning(_ algorithm: Algorithm, learning: Bool) {
        storedLearningAlgorithms[algorithm.name] = learning
    }
    
    func toggleAlgorithmForLearning(_ algorithm: Algorithm) {
        markAlgorithmForLearning(algorithm, learning: !algorithmIsLearning(algorithm))
    }
    
    var learningAlgorithms: [(String, [AlgorithmGroup])] {
        SolveStep.allCases.map { step in
            (step.title, algorithms(for: step).map { group in
                AlgorithmGroup(
                    name: group.name,
                    algorithms: group.algorithms.filter { algorithmIsLearning($0) }
                )
            })
        }
    }
    
    func mnemonics(for steps: String) -> [StepMnemonic] {
        mnemonics[steps] ?? []
    }
    
    func updateMnemonics(_ newMnemonics: [StepMnemonic], for steps: String) {
        mnemonics[steps] = newMnemonics
    }
}

private extension AlgorithmsManager {
    enum DefaultKeys: String, DefaultsKey {
        case learnedAlgorithms = "LEARNED_ALGORITHMS"
        case mnemonics = "MNEMONICS"
    }
}
