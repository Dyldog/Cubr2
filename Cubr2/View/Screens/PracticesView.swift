//
//  PracticesView.swift
//  Cubr2
//
//  Created by Dylan Elliott on 24/6/2025.
//

import SwiftUI

class PracticesViewModel: ObservableObject {
    typealias Label = (Int, Image)
    
    let algorithmsManager: AlgorithmsManager
    
    var days: [Day] {
        tests
            .filter { $0.value.isEmpty == false }
            .keys
            .sorted(by: >)
    }
    
    @Published var tests: [Day: [(AlgorithmWithMethod, [Label])]] = [:]
    
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
    
    private func algorithms(for day: Day) -> [AlgorithmWithMethod] {
        algorithmsManager.testAlgorithms(for: day, includeAll: true)
    }
    
    private func labels(for day: Day) -> [(AlgorithmWithMethod, [Label])] {
        algorithms(for: day).map { algorithm in
            (algorithm, labels(for: algorithm.algorithm, on: day))
        }
        .filter { $0.1.isEmpty == false }
    }
    
    private func labels(for algorithm: Algorithm, on day: Day) -> [Label] {
        algorithmsManager.learningEvents(for: algorithm, on: day)
            .uniqueCount
            .sorted { $0.key < $1.key }
            .map { ($0.value, $0.key.image)}
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
    let labels: [(Int, Image)]
    
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
    let label: (Int, Image)
    
    var body: some View {
        VStack {
            Text("\(label.0)")
                .font(.system(size: 48))
            label.1.bold()
        }
        .padding([.bottom, .horizontal])
        .padding(.top, 4)
    }
}
