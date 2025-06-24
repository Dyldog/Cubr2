//
//  String+Moves.swift
//  Cubr2
//
//  Created by Dylan Elliott on 17/6/2025.
//

import DylKit
import Foundation

extension String {
    var isDoubleRotation: Bool { contains("2") }
    var rotations: Int { isDoubleRotation ? 2 : 1 }
    
    var steps: [String] { components(separatedBy: " ") }
    
    var moves: Int {
        steps.moves
    }
    
    func moves(chunk: Int) -> [[String]] {
        steps.moves(chunk: chunk)
    }
}

extension Array where Element == String {
    var moves: Int {
        map { $0.rotations }.sum()
    }
    
    func moves(chunk: Int) -> [[String]] {
        reduce(into: [[]]) { partialResult, nextStep in
            if ((partialResult.last ?? []) + [nextStep]).moves > chunk {
                partialResult.append([nextStep])
            } else {
                partialResult[partialResult.lastIndex ?? 0].append(nextStep)
            }
        }
    }
}
