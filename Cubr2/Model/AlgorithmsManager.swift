//
//  AlgorithmsManager.swift
//  Cubr2
//
//  Created by Dylan Elliott on 10/6/2025.
//

import DylKit
import UIKit

class AlgorithmsManager: ObservableObject, AlgorithmsManaging {
    static var shared: AlgorithmsManager = .init()
    
    @UserDefaultable(key: DefaultKeys.learnedAlgorithms)
    private var storedLearningAlgorithms: [String: Bool] = [:]
    
    @UserDefaultable(key: DefaultKeys.mnemonics) 
    private var mnemonics: [String: [StepMnemonic]] = [:]
    
    @UserDefaultable(key: DefaultKeys.bestTimes)
    private var bestTimes: [String: [SolveAttempt]] = [:]
    
    @UserDefaultable(key: DefaultKeys.enabledMethods)
    private var enabledMethods: [SolveMethod: Bool] = [:]
    
    private func data(for step: any SolveStep) -> AlgorithmGroupData {
        let url = Bundle.main.url(forResource: step.file, withExtension: "json")!
        let data = try! Data(contentsOf: url)
        return try! JSONDecoder().decode(AlgorithmGroupData.self, from: data)
    }
    
    func algorithms(for step: any SolveStep) -> [AlgorithmGroup] {
        let data = data(for: step)
        
        let algs = zip(data.algorithms, data.safeScrambles)
            .map { algorithm, scrambles in
                (group: algorithm.group, algorithm: Algorithm(
                    name: algorithm.name,
                    description: algorithm.description,
                    stepSets: algorithm.alg,
                    scrambles: scrambles.scrambles.mapIf(step.operatesOnFlipped) {
                        $0.withCubeFlip
                    }
                ))
            }
        
        let groups = Dictionary(grouping: algs, by: { $0.group })
            .map { name, algorithms in
                AlgorithmGroup(
                    name: name,
                    description: data.groupDescriptions?[name],
                    algorithms: algorithms.map { $0.algorithm }
                )
            }
        .sorted {
            $0.name < $1.name
        }
        
        return groups
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
    
    var methodsEnabled: [SolveMethod] {
        SolveMethod.allCases.filter { methodEnabled($0) }
    }
    
    var learningAlgorithms: [AlgorithmMethod] {
        methodsEnabled.algorithms(with: self) {
            algorithmIsLearning($0)
        }
    }
    
    func mnemonics(for steps: String) -> [StepMnemonic] {
        mnemonics[steps] ?? []
    }
    
    func updateMnemonics(_ newMnemonics: [StepMnemonic], for steps: String) {
        objectWillChange.send()
        mnemonics[steps] = newMnemonics
    }
    
    func attempts(for timeable: Timeable) -> [SolveAttempt] {
        bestTimes[timeable.id, default: []]
    }
    
    func bestTime(for timeable: Timeable) -> Duration? {
        attempts(for: timeable)
            .sorted { $0.time < $1.time }
            .first?
            .time
    }
    
    func addTime(_ duration: Duration, for timeable: Timeable, with scramble: [String]) {
        objectWillChange.send()
        bestTimes[timeable.id, default: []].append(
            SolveAttempt(id: .init(), date: .now, time: duration, scramble: scramble)
        )
    }
    
    func deleteTime(_ attempt: SolveAttempt, for timeable: Timeable) {
        objectWillChange.send()
        bestTimes[timeable.id, default: []].removeAll { $0.id == attempt.id }
    }
    
    func methodEnabled(_ method: SolveMethod) -> Bool {
        enabledMethods[method] ?? true
    }
    
    func updateMethodEnabled(_ enabled: Bool, for method: SolveMethod) {
        objectWillChange.send()
        enabledMethods[method] = enabled
    }
}

private extension AlgorithmsManager {
    enum DefaultKeys: String, DefaultsKey {
        case learnedAlgorithms = "LEARNED_ALGORITHMS"
        case mnemonics = "MNEMONICS"
        case bestTimes = "BEST_TIMES"
        case enabledMethods = "ENABLED_METHODS"
    }
}

private extension AlgorithmGroupData {
    func zipped() -> [(algorithms: AlgorithmData, scrambles: [String])] {
        zip(algorithms, scrambles).map { $0 }
    }
}

extension Array {
    func grouping<Key: Hashable>(by grouper: (Element) -> Key) -> Dictionary<Key, [Element]> {
        Dictionary(grouping: self, by: grouper)
    }
}
