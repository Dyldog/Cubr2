//
//  StepMnemonic.swift
//  Cubr2
//
//  Created by Dylan Elliott on 14/6/2025.
//

import Foundation

struct StepMnemonic: Hashable, Codable {
    let id: UUID
    let text: String
    let location: Int
    let length: Int
                
    var range: Range<Int> { (location ..< location + length) }
}
