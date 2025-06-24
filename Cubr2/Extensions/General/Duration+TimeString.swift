//
//  Duration+TimeString.swift
//  Cubr2
//
//  Created by Dylan Elliott on 17/6/2025.
//

import Foundation

extension Duration {
    var timeString: String {
        formatted(.time(pattern: .minuteSecond(padMinuteToLength: 0, fractionalSecondsLength: 2)))
    }
}
