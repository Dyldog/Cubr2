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
    let timeable: Timeable
    
    @State private var sortOrder: SortOrder = .byTime
    @State private var testTime: SolveAttempt?
    
    var times: [SolveAttempt] {
        algorithmsManager.attempts(for: timeable).sorted(by: sortOrder)
    }
    
    var body: some View {
        List {
            ForEach(times) { time in
                Button {
                    testTime = time
                } label: {
                    row(for: time)
                }
                .buttonStyle(.plain)

            }
        }
        .toolbar {
            Button(systemName: "arrow.up.arrow.down") {
                sortOrder = sortOrder.next
            }
        }
        .navigationTitle("Times for \(timeable.name)")
        .sheet(item: $testTime) { time in
            NavigationStack {
                sheet(for: time)
            }
        }
    }
    
    private func row(for time: SolveAttempt) -> some View {
        VStack(alignment: .leading) {
            HStack(alignment: .firstTextBaseline) {
                Text(time.time.timeString)
                    .font(.largeTitle)
                    .fixedSize()
                
                Text(time.date.description)
                    .foregroundStyle(.gray)
                    .font(.footnote)
                    .frame(maxWidth: .infinity)
            }
            
            WrappingHStack(verticalSpacing: 6) {
                ForEach(time.scramble.moves(chunk: 4)) { steps in
                    MnemonicButton(
                        text: steps.joined(separator: " "),
                        highlighted: false,
                        onTap: { }
                    )
                    .font(.system(size: 20))
                }
            }
            .allowsHitTesting(false)
            .padding(.horizontal)
        }
        .swipeActions {
            Button(systemName: "trash") {
                algorithmsManager.deleteTime(time, for: timeable)
            }
            .tint(.red)
        }
    }
    
    @ViewBuilder
    private func sheet(for time: SolveAttempt) -> some View {
        switch timeable {
        case let .algorithm(algorithm):
            AlgorithmTestView(viewModel: .init(forcedAlgorithm: algorithm))
        case .cube:
            CubeTestView(viewModel: .init(forcedScramble: time.scramble))
        }
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
