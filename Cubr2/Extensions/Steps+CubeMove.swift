//
//  Steps+CubeMove.swift
//  Cubr2
//
//  Created by Dylan Elliott on 17/6/2025.
//

import Foundation

extension String {
    var cubeMoves: [CubeMove]! {
        switch self {
        case "U": return [.U]
        case "U2": return [.U, .U]
        case "U'": return [.UPrime]
        case "D": return [.D]
        case "D2": return [.D, .D]
        case "D'": return [.DPrime]
        case "L": return [.L]
        case "L2": return [.L, .L]
        case "L'": return [.LPrime]
        case "M": return [.M]
        case "M2": return [.M, .M]
        case "M'": return [.MPrime]
        case "R": return [.R]
        case "R2": return [.R, .R]
        case "R'": return [.RPrime]
        case "r": return [.R, .MPrime]
        case "r'": return [.RPrime, .M]
        case "F": return [.F]
        case "F2": return [.F, .F]
        case "F'": return [.FPrime]
        case "B": return [.B]
        case "B2": return [.B, .B]
        case "B'": return [.BPrime]
        default: fatalError()
        }
    }
}
extension Array where Element == String {
    var cubeMoves: [CubeMove] { flatMap { $0.cubeMoves } }
}
