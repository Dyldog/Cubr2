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
    
    @UserDefaultable(key: DefaultKeys.bestTimes)
    private var bestTimes: [String: [SolveAttempt]] = [:]
    
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
        objectWillChange.send()
        mnemonics[steps] = newMnemonics
    }
    
    func attempts(for algorithm: Algorithm) -> [SolveAttempt] {
        bestTimes[algorithm.name, default: []]
    }
    
    func bestTime(for algorithm: Algorithm) -> Duration? {
        attempts(for: algorithm)
            .sorted { $0.time < $1.time }
            .first?
            .time
    }
    
    func addTime(_ duration: Duration, for algorithm: Algorithm) {
        objectWillChange.send()
        bestTimes[algorithm.name, default: []].append(
            SolveAttempt(id: .init(), date: .now, time: duration)
        )
    }
    
    func deleteTime(_ attempt: SolveAttempt, for algorithm: Algorithm) {
        objectWillChange.send()
        bestTimes[algorithm.name, default: []].removeAll { $0.id == attempt.id }
    }
}

private extension AlgorithmsManager {
    enum DefaultKeys: String, DefaultsKey {
        case learnedAlgorithms = "LEARNED_ALGORITHMS"
        case mnemonics = "MNEMONICS"
        case bestTimes = "BEST_TIMES"
    }
}
