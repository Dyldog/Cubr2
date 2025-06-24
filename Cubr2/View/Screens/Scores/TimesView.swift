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
    @State private var hideWithHints: Bool
    
    init(
        timeable: Timeable,
        hideWithHints: Bool = false
    ) {
        self.timeable = timeable
        self._hideWithHints = .init(initialValue: hideWithHints)
    }
    
    var times: [SolveAttempt] {
        algorithmsManager
            .attempts(for: timeable).sorted(by: sortOrder)
            .if(hideWithHints) {
                $0.filter { $0.hints == 0 }
            }
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
            Button(systemName: hideWithHints ? "eye.slash.fill" : "eye.fill") {
                hideWithHints.toggle()
            }
            
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
        TimeRow(time: time)
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

struct TimeRow: View {
//    @State var showHint: Bool = false
    let time: SolveAttempt
    
    var body: some View {
        VStack(alignment: .leading) {
            
            HStack {
                Text(time.time.timeString)
                    .font(.system(size: 48))
                    .fixedSize()
                
                Spacer()
                
                VStack {
                    if time.hints > 0 {
                        Text("\(time.hints) \("hint".pluralise(time.hints)) used")
                            .font(.footnote)
                    }
                    
                    Text(time.date.formatted(date: .numeric, time: .omitted))
                        .foregroundStyle(.gray)
                        .font(.footnote)
                }
                
//                Button(systemName: "eye.fill") {
//                    showHint = true
//                }
            }
            
//            if showHint {
//                ScrambleLabel(scramble: time.scramble, fontSize: 20)
//                    .allowsHitTesting(false)
//                    .padding(.horizontal)
//            }
        }
        .id(time)
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
