//
//  Steps+CubeMove.swift
//  Cubr2
//
//  Created by Dylan Elliott on 17/6/2025.
//

import Foundation

extension String {
    func applied(to moves: [CubeMove]) -> [CubeMove] {
        switch self {
        case "U": return [.U]
        case "u": return [.U, .EPrime]
        case "E": return [.E]
        case "D": return [.D]
        case "d": return [.D, .E]
        case "L": return [.L]
        case "l": return [.L, .M]
        case "M": return [.M]
        case "R": return [.R]
        case "r": return [.R, .MPrime]
        case "F": return [.F]
        case "f": return [.F, .S]
        case "S": return [.S]
        case "B": return [.B]
        case "b": return [.B, .SPrime]
        case "2": return moves.repeated(2)
        case "'": return moves.map(\.inverse)
        default: fatalError("Unknown move string '\(self)'")
        }
    }
    
    var cubeMoves: [CubeMove]! {
        reduce([], { String($1).applied(to: $0) })
    }
}
extension Array where Element == String {
    var cubeMoves: [CubeMove] { flatMap { $0.cubeMoves } }
}
