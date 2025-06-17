//
//  TimesView.swift
//  Cubr2
//
//  Created by Dylan Elliott on 17/6/2025.
//

import DylKit
import SwiftUI

struct TimesView: View {
    @ObservedObject private var algorithmsManager: AlgorithmsManager = .shared
    let algorithm: Algorithm
    
    @State private var sortOrder: SortOrder = .byTime
    
    var times: [SolveAttempt] {
        algorithmsManager.attempts(for: algorithm).sorted(by: sortOrder)
    }
    
    var body: some View {
        List {
            ForEach(times) { time in
                VStack(alignment: .leading) {
                    Text(time.date.description)
                        .foregroundStyle(.gray)
                        .font(.footnote)
                    
                    Text(time.time.formatted(.time(pattern: .minuteSecond(padMinuteToLength: 2, fractionalSecondsLength: 2))))
                }
                .swipeActions {
                    Button(systemName: "trash") {
                        algorithmsManager.deleteTime(time, for: algorithm)
                    }
                    .tint(.red)
                }
            }
        }
        .toolbar {
            Button(systemName: "arrow.up.arrow.down") {
                sortOrder = sortOrder.next
            }
        }
        .navigationTitle("Times for \(algorithm.name)")
    }
}

extension TimesView {
    enum SortOrder: Int {
        case byDate
        case byTime
        
        var next: SortOrder {
            .init(rawValue: rawValue + 1) ?? .byDate
        }
    }
}

private extension Array where Element == SolveAttempt {
    func sorted(by sortOrder: TimesView.SortOrder) -> Self {
        sorted {
            switch sortOrder {
            case .byDate: $0.date > $1.date
            case .byTime: $0.time < $1.time
            }
        }
    }
}
