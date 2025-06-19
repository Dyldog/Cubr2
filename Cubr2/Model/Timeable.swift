//
//  Timeable.swift
//  Cubr2
//
//  Created by Dylan Elliott on 19/6/2025.
//

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
