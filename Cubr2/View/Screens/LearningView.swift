//
//  LearningView.swift
//  Cubr2
//
//  Created by Dylan Elliott on 12/6/2025.
//

import SwiftUI

class LearningViewModel: ObservableObject, MnemonicsHandling {
    let algorithmsManager: AlgorithmsManager = .shared

    @Published private(set) var algorithms: [(String, [AlgorithmGroup])] = []
    @Published var learningAlgorithm: Algorithm?
    
    init() {
        reload()
    }
    
    func reload() {
        algorithms = algorithmsManager.learningAlgorithms
    }
    
    var randomAlgorithm: Algorithm? {
        algorithms.flatMap { $0.1 }.flatMap { $0.algorithms }.randomElement()
    }
}

struct LearningView: View {
    @StateObject var viewModel: LearningViewModel = .init()
    
    var body: some View {
        List {
            ForEach(viewModel.algorithms, id: \.0) { stage in
                Section(stage.0) {
                    ForEach(stage.1) { group in
                        groupView(for: group)
                    }
                }
            }
        }
        .navigationTitle("Learning")
        .toolbar {
            Button(systemName: "brain.fill") {
                viewModel.learningAlgorithm = viewModel.randomAlgorithm
            }
        }
        .sheet(item: $viewModel.learningAlgorithm) { algorithm in
            NavigationStack {
                ScrambleView(algorithm: algorithm)
            }
        }
        .onAppear {
            viewModel.reload()
        }
    }
    
    private func groupView(for group: AlgorithmGroup) -> some View {
        ForEach(group.algorithms) { algorithm in
            AlgorithmView(algorithm: algorithm, mnemonicsHandler: viewModel) {
                viewModel.learningAlgorithm = algorithm
            }
        }
    }
}
