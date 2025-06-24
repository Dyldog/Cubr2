//
//  ContentView.swift
//  Cubr2
//
//  Created by Dylan Elliott on 10/6/2025.
//

import SwiftUI

class ContentViewModel: ObservableObject, AlgorithmHandling {
    private let step: any SolveStep
    
    let algorithmsManager: AlgorithmsManager = .init()
    
    @Published private(set) var algorithms: [AlgorithmGroup] = []
    @Published var showScramble: AlgorithmWithMethod?
    
    var title: String { step.title }
    var method: SolveMethod { step.method }
    
    init(step: any SolveStep) {
        self.step = step
        reload()
    }
    
    func reload() {
        algorithms = algorithmsManager.algorithms(for: step)
    }
    
    func backgroundColor(_ algorithm: Algorithm) -> Color {
        switch algorithmsManager.algorithmLearningStatus(algorithm) {
        case .none: .white
        case .learning: swipeColor(for: .learning)
        case .learned: swipeColor(for: .learned)
        }
    }
    
    func swipeColor(for status: LearningStatus?) -> Color {
        switch status {
        case .none: .red
        case .learning: .actualYellow
        case .learned: .actualGreen
        }
    }
    
    func swipeImage(for status: LearningStatus?) -> Image {
        switch status {
        case .learning: Image(systemName: "brain.fill")
        case .learned: Image(systemName: "graduationcap.fill")
        case .none: Image(systemName: "trash")
        }
    }
    
    func swipeAction(for status: LearningStatus?, for algorithm: Algorithm) {
        switch status {
        case .none: algorithmsManager.markAlgorithmForLearning(algorithm, status: nil)
        case .learning: algorithmsManager.markAlgorithmForLearning(algorithm, status: .learning)
        case .learned: algorithmsManager.markAlgorithmForLearning(algorithm, status: .learned)
        }
        
        reload()
    }
    
    func swipeButtons(for algorithm: Algorithm) -> [(color: Color, image: Image, action: () -> Void)] {
        let learningStatus = algorithmsManager.algorithmLearningStatus(algorithm).next
        
        return [
            (swipeColor(for: learningStatus), swipeImage(for: learningStatus), { [weak self] in
                self?.swipeAction(for: learningStatus, for: algorithm)
            })
        ]
    }
    
    func scramble(for algorithm: Algorithm) -> Scramble {
        algorithm.scrambles.first ?? []
    }
}

struct ContentView: View {
    
    @StateObject var viewModel: ContentViewModel
    
    init(step: any SolveStep) {
        _viewModel = .init(wrappedValue: .init(step: step))
    }
    
    var body: some View {
        List {
            ForEach(viewModel.algorithms, id: \.self) {
                group($0)
            }
        }
        .navigationTitle(viewModel.title)
        .sheet(item: $viewModel.showScramble) { algorithm in
            NavigationStack {
                ScrambleView(
                    algorithm: algorithm,
                    scramble: viewModel.scramble(for: algorithm.algorithm)
                )
            }
        }
    }
    
    private func group(_ group: AlgorithmGroup) -> some View {
        Section {
            ForEach(group.algorithms, id: \.self) {
                algorithm(.init(method: viewModel.method, algorithm: $0))
            }
        } header: {
            Text(group.name)
                .bold()
                .font(.largeTitle)
        }
    }
    
    private func algorithm(_ algorithm: AlgorithmWithMethod) -> some View {
        AlgorithmView(algorithm: algorithm, handler: viewModel) {
            viewModel.showScramble = algorithm
        }
        .listRowBackground(viewModel.backgroundColor(algorithm.algorithm))
        .swipeActions {
            ForEach(viewModel.swipeButtons(for: algorithm.algorithm)) { button in
                Button {
                    button.action()
                } label: {
                    button.image
                }
                .tint(button.color)
            }
            
        }
    }
}

#Preview {
    ContentView(step: CFOPSolveStep.twoLookOLL)
}
