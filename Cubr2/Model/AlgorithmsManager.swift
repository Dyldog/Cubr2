//
//  AlgorithmsManager.swift
//  Cubr2
//
//  Created by Dylan Elliott on 10/6/2025.
//

import DylKit
import UIKit

enum Timeable: Hashable {
    case algorithm(AlgorithmWithMethod)
    case cube
    
    var id: String {
        switch self {
        case let .algorithm(algorithm): "ALGORITHM: \(algorithm.algorithm.name)"
        case .cube: "CUBE"
        }
    }
    
    var image: UIImage {
        switch self {
        case let .algorithm(algorithm): algorithm.algorithm.image
        case .cube: .init(named: "Full Cube")!
        }
    }
    
    var name: String {
        switch self {
        case let .algorithm(algorithm): algorithm.algorithm.name
        case .cube: TestMode.cube.title
        }
    }
}

class AlgorithmsManager: ObservableObject {
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
        
        return data.algorithms.enumerated().reduce(into: [:]) { groups, algorithm in
            groups[algorithm.element.group, default: []].append(
                Algorithm(
                    name: algorithm.element.name,
                    stepSets: algorithm.element.alg,
                    scrambles: data.scrambles[safe: algorithm.offset] ?? []
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
    
    var methodsEnabled: [SolveMethod] {
        SolveMethod.allCases.filter { methodEnabled($0) }
    }
    
    var learningAlgorithms: [AlgorithmMethod] {
        methodsEnabled.reduce(into: []) { partialResult, method in
            partialResult.append(
                AlgorithmMethod(method: method, stages: method.steps.map { step in
                    AlgorithmStage(title: step.title, groups: algorithms(for: step).map { group in
                        AlgorithmGroup(
                            name: group.name,
                            algorithms: group.algorithms.filter { algorithmIsLearning($0) }
                        )
                    }.filter { $0.algorithms.isEmpty == false })
                }.filter { $0.groups.isEmpty == false }))
        }
        .filter { $0.stages.isEmpty == false }
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
