//
//  Steps+All.swift
//  Cubr2
//
//  Created by Dylan Elliott on 18/6/2025.
//

import Foundation

extension String {
    private static var allSides: [String] { ["L", "R", "U", "D", "F", "B", "M"] }
    private static var allPrimes: [String] { allSides.map { "\($0)'" } }
    private static var allDoubles: [String] { allSides.map { "\($0)2" } }
    private static var allShorts: [String] { allSides + allPrimes + allDoubles }
    
    private static var allWideSides: [String] {
        allSides.filter { ["M"].contains($0) == false}.map { $0.lowercased() }
    }
    private static var allWidePrimes: [String] { allWideSides.map { "\($0)'" } }
    private static var allWides: [String] { allWideSides + allWidePrimes }
    
    static var allMoves: [String] { allShorts + allWides }
    
    static var randomMove: String { allMoves.randomElement() ?? "NO MOVE!" }
    
    static func randomMoves(_ count: Int) -> [String] {
        (0 ..< count).map { _ in randomMove }
    }
}
