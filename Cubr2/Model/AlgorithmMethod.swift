//
//  AlgorithmMethod.swift
//  Cubr2
//
//  Created by Dylan Elliott on 17/6/2025.
//

import Foundation

struct AlgorithmMethod: Hashable {
    let method: SolveMethod
    let stages: [AlgorithmStage]
}

extension Array where Element == AlgorithmMethod {
    func algorithms<T>(
        mapper: (
            AlgorithmMethod,
            AlgorithmStage,
            AlgorithmGroup,
            Algorithm
        ) -> T) -> [T] {
            flatMap {
                $0.algorithms(mapper: mapper)
            }
    }
}
extension AlgorithmMethod {
    func algorithms<T>(
        mapper: (
            AlgorithmMethod,
            AlgorithmStage,
            AlgorithmGroup,
            Algorithm
        ) -> T) -> [T] {
            stages.flatMap {
                $0.algorithms { stage, group, algorithm in
                    mapper(self, stage, group, algorithm)
                }
            }
    }
}

extension AlgorithmStage {
    func algorithms<T>(
        mapper: (AlgorithmStage, AlgorithmGroup, Algorithm) -> T) -> [T] {
            groups.flatMap {
                $0.algorithms { group, algorithm in
                    mapper(self, group, algorithm)
                }
            }
    }
}

extension AlgorithmGroup {
    func algorithms<T>(mapper: (AlgorithmGroup, Algorithm) -> T) -> [T] {
        algorithms.map { mapper(self, $0) }
    }
}
