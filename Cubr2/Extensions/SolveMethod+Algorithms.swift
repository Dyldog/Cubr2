//
//  SolveMethod+Algorithms.swift
//  Cubr2
//
//  Created by Dylan Elliott on 19/6/2025.
//

import Foundation

protocol AlgorithmsManaging {
    func algorithms(for step: any SolveStep) -> [AlgorithmGroup]
}

extension Array where Element == SolveMethod {
    func algorithms(
        with manager: AlgorithmsManaging, 
        and filter: (Algorithm) -> Bool
    ) -> [AlgorithmMethod] {
        map {
            $0.algorithm(with: manager, and: filter)
        }
        .filter { $0.stages.isEmpty == false }
    }
}
extension SolveMethod {
    func algorithm(
        with manager: AlgorithmsManaging,
        and filter: (Algorithm) -> Bool
    ) -> AlgorithmMethod {
        AlgorithmMethod(method: self, stages: steps.map { step in
            step.algorithm(with: manager, and: filter)
        }.filter { $0.groups.isEmpty == false })
    }
}

extension SolveStep {
    func algorithm(
        with manager: AlgorithmsManaging,
        and filter: (Algorithm) -> Bool
    ) -> AlgorithmStage {
        AlgorithmStage(
            title: title,
            description: description,
            groups: manager.algorithms(for: self).map { group in
                AlgorithmGroup(
                    name: group.name,
                    description: group.description,
                    algorithms: group.algorithms.filter { filter($0) }
                )
            }.filter { $0.algorithms.isEmpty == false }
        )
    }
}
