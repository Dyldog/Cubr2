//
//  Day.swift
//  Cubr2
//
//  Created by Dylan Elliott on 24/6/2025.
//

import Foundation

struct Day: Hashable, Codable, Comparable, Identifiable {
    let day: Int
    let month: Int
    let year: Int
    
    var id: String { "D:\(day)M:\(month)Y:\(year)"}
    
    static var today: Day {
        Calendar.autoupdatingCurrent.today
    }
    
    static func < (lhs: Day, rhs: Day) -> Bool {
        lhs.year < rhs.year && lhs.month < rhs.month && lhs.day < rhs.day
    }
    
    var string: String {
        "\(day)/\(month)/\(year)"
    }
}

extension Calendar {
    var today: Day {
        let comps = dateComponents([.year, .month, .day], from: .now)
        return .init(day: comps.day!, month: comps.month!, year: comps.year!)
    }
}
