//
//  String+CubeFlip.swift
//  Cubr2
//
//  Created by Dylan Elliott on 21/6/2025.
//

import Foundation

extension Scramble {
    private var cubeFlip: [String] {
        ["L", "M", "R"].repeated(2)
    }
    var withCubeFlip: [String] {
        cubeFlip + self
    }
}
