//
//  LearningView.swift
//  Cubr2
//
//  Created by Dylan Elliott on 12/6/2025.
//

import SwiftUI

struct AlgorithmWithMethod: Hashable, Identifiable {
    let method: SolveMethod
    let algorithm: Algorithm
}

extension AlgorithmWithMethod {
    var name: String { algorithm.name }
    var description: String? { algorithm.description }
    var stepSets: [String] { algorithm.stepSets }
    var scrambles: [String] { algorithm.scrambles }
    
    var id: Int {
        var hasher = Hasher()
        hasher.combine(algorithm)
        hasher.combine(method)
        return hasher.finalize()
    }
    
    var image: UIImage { algorithm.image }
    var defaultStepsString: String { algorithm.defaultStepsString }
    var defaultSteps: [String] { algorithm.defaultSteps }
}

class LearningViewModel: ObservableObject, AlgorithmHandling {
    let algorithmsManager: AlgorithmsManager = .shared

    @Published private(set) var algorithms: [AlgorithmMethod] = []
    @Published var learningAlgorithm: AlgorithmWithMethod?
    
    init() {
        reload()
    }
    
    func reload() {
        algorithms = algorithmsManager.learningAlgorithms
    }
    
    var randomAlgorithm: AlgorithmWithMethod? {
        algorithms.algorithms { method, _, _, algorithm in
            .init(method: method.method, algorithm: algorithm)
        }
        .randomElement()
    }
    
    func scramble(for algorithm: Algorithm) -> [String] {
        algorithm.scrambles.first!.components(separatedBy: " ")
    }
}

struct LearningView: View {
    @StateObject var viewModel: LearningViewModel = .init()
    
    var body: some View {
        List {
            ForEach(viewModel.algorithms) { method in
                ForEach(method.stages) { stage in
                    stageView(for: stage, in: method.method)
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
                ScrambleView(
                    algorithm: algorithm,
                    scramble: viewModel.scramble(for: algorithm.algorithm)
                )
            }
        }
        .onAppear {
            viewModel.reload()
        }
    }
    
    private func stageView(for stage: AlgorithmStage, in method: SolveMethod) -> some View {
        Section(stage.title) {
            ForEach(stage.groups) { group in
                groupView(for: group, in: method)
            }
        }
    }
    
    private func groupView(for group: AlgorithmGroup, in method: SolveMethod) -> some View {
        ForEach(group.algorithms) { algorithm in
            AlgorithmView(
                algorithm: .init(method: method, algorithm: algorithm), 
                handler: viewModel
            ) {
                viewModel.learningAlgorithm = .init(method: method, algorithm: algorithm)
            }
        }
    }
}
