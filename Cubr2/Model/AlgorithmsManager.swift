//
//  AlgorithmsManager.swift
//  Cubr2
//
//  Created by Dylan Elliott on 10/6/2025.
//

import DylKit
import UIKit

enum LearningStatus: Codable {
    case learning
    case learned
}

extension Optional where Wrapped == LearningStatus {
    var next: LearningStatus? {
        switch self {
        case .none: .learning
        case .learning: .learned
        case .learned: .none
        }
    }
}

class AlgorithmsManager: ObservableObject, AlgorithmsManaging {
    static var shared: AlgorithmsManager = .init()
    
    @UserDefaultable(key: DefaultKeys.learnedAlgorithms)
    private var storedLearningAlgorithms: [String: LearningStatus] = [:]
    
    @UserDefaultable(key: DefaultKeys.mnemonics) 
    private var mnemonics: [String: [StepMnemonic]] = [:]
    
    @UserDefaultable(key: DefaultKeys.bestTimes)
    private var bestTimes: [String: [SolveAttempt]] = [:]
    
    @UserDefaultable(key: DefaultKeys.enabledMethods)
    private var enabledMethods: [SolveMethod: Bool] = [:]
    
    @UserDefaultable(key: DefaultKeys.learningEvents)
    private var learningEvents: [Day: [String: [LearningEvent]]] = [:]
    
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
    
    func algorithmLearningStatus(_ algorithm: Algorithm) -> LearningStatus? {
        storedLearningAlgorithms[algorithm.name]
    }
    
    func markAlgorithmForLearning(_ algorithm: Algorithm, status: LearningStatus?) {
        objectWillChange.send()
        storedLearningAlgorithms[algorithm.name] = status
    }
    
    var methodsEnabled: [SolveMethod] {
        SolveMethod.allCases.filter { methodEnabled($0) }
    }
    
    var learningAlgorithms: [AlgorithmMethod] {
        methodsEnabled.algorithms(with: self) {
            algorithmLearningStatus($0) == .learning
        }
    }
    
    var learnedAndLearningAlgorithms: [AlgorithmMethod] {
        methodsEnabled.algorithms(with: self) {
            algorithmLearningStatus($0) != nil
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
    
    func bestTime(for timeable: Timeable, withoutHints: Bool = false) -> SolveTime? {
        attempts(for: timeable)
            .if(withoutHints) { times in times.filter { $0.hints == 0 } }
            .sorted { $0.time < $1.time }
            .first
            .map { .init(time: $0.time, hints: $0.hints) }
    }
    
    func addTime(_ duration: Duration, with hints: Int, for timeable: Timeable, with scramble: [String]) {
        objectWillChange.send()
        bestTimes[timeable.id, default: []].append(
            SolveAttempt(id: .init(), date: .now, time: duration, hints: hints, scramble: scramble)
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
    
    var maxLearnedCountForToday: Int {
        let learningAlgorithmNames = learningAlgorithms.algorithms.map { $0.name }
        return learningEvents[.today]?
            .filter { learningAlgorithmNames.contains($0.key) }
            .map { $0.value.count }.min() ?? 0
    }
    
    func testAlgorithms(
        for day: Day = .today,
        countForLearned: Int? = LearningEvent.countForLearned,
        includeLearned: Bool = false
    ) -> [AlgorithmWithMethod] {
        var baseArray = includeLearned ? learnedAndLearningAlgorithms : learningAlgorithms
        
        guard let countForLearned else { return baseArray.algorithmsWithMethod }
        
        let alreadyTested = learningEvents[day, default: [:]]
            .filter { $0.value.count >= countForLearned }.keys
        
        return baseArray.algorithmsWithMethod
            .filter { !alreadyTested.contains($0.name) }
    }
    
    var learningDays: [Day] {
        Array(learningEvents.keys)
    }
    
    func learningEvents(for algorithm: Algorithm, on day: Day = .today) -> [LearningEvent] {
        learningEvents[day, default: [:]][algorithm.name, default: []]
    }
    
    func allLearningEvents(for algorithm: Algorithm) -> [Day: [LearningEvent]] {
        learningDays.reduce(into: [:]) { partialResult, day in
            partialResult[day] = learningEvents(for: algorithm, on: day)
        }
        .filter { $0.value.isEmpty == false }
    }
    
    func updateLearningEvents(
        for algorithm: Algorithm,
        to newEvents: [LearningEvent],
        on day: Day = .today
    ) {
        learningEvents[day, default: [:]][algorithm.name] = newEvents
    }
}

private extension AlgorithmsManager {
    enum DefaultKeys: String, DefaultsKey {
        case learnedAlgorithms = "LEARNED_ALGORITHMS"
        case mnemonics = "MNEMONICS"
        case bestTimes = "BEST_TIMES"
        case enabledMethods = "ENABLED_METHODS"
        case learningEvents = "LEARNING_EVENTS"
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

