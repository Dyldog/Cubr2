//
//  PracticesView.swift
//  Cubr2
//
//  Created by Dylan Elliott on 24/6/2025.
//

import SwiftUI

class PracticesViewModel: ObservableObject, PracticesHandling {
    let algorithmsManager: AlgorithmsManager
    
    var days: [Day] {
        tests
            .filter { $0.value.isEmpty == false }
            .keys
            .sorted(by: >)
    }
    
    @Published var tests: [Day: [(AlgorithmWithMethod, [PracticesHandling.Label])]] = [:]
    
    init(algorithmsManager: AlgorithmsManager = .shared) {
        self.algorithmsManager = algorithmsManager
        reload()
    }
    
    func reload() {
        tests = algorithmsManager.learningDays
            .reduce(into: [:], { days, day in
                days[day] = labels(for: day)
            })
    }
    
    func deletePractices(for algorithm: Algorithm, on day: Day) {
        algorithmsManager.updateLearningEvents(for: algorithm, to: [], on: day)
        reload()
    }
}

struct PracticesView: View {
    @StateObject var viewModel: PracticesViewModel = .init()
    
    var body: some View {
        List(viewModel.days) { day in
            Section(day.string) {
                ForEach(viewModel.tests[day] ?? []) { (algorithm, labels) in
                    PracticeRow(
                        algorithm: algorithm,
                        labels: labels
                    )
                    .swipeActions {
                        Button(systemName: "trash") {
                            viewModel.deletePractices(for: algorithm.algorithm, on: day)
                        }
                        .tint(.red)
                    }
                }
            }
        }
        .navigationTitle("Past Tests")
    }
}

struct PracticeRow: View {
    let algorithm: AlgorithmWithMethod
    let labels: [PracticesHandling.Label]
    
    var body: some View {
        AlgorithmView(
            algorithm: algorithm,
            bestTime: nil, // TODO
            content: {
                HStack {
                    Spacer()
                    
                    ForEach(labels) {
                        PracticeLabel(label: $0)
                    }
                    
                    Spacer()
                }
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.accentColor, lineWidth: 3)
                }
                .padding(.leading)
            },
            iconTapped: { }
        )
    }
}

struct PracticeLabel: View {
    let label: PracticesHandling.Label
    
    var body: some View {
        VStack {
            Text("\(label.0)")
                .font(.system(size: 48))
                .fixedSize()
            label.2.bold()
        }
        .padding([.bottom, .horizontal])
        .padding(.top, 4)
        .foregroundStyle(label.1)
    }
}
