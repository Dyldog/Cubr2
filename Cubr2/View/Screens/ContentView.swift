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
    
    func algorithmIsLearning(_ algorithm: Algorithm) -> Bool {
        algorithmsManager.algorithmIsLearning(algorithm)
    }
    
    func toggleAlgorithmForLearning(_ algorithm: Algorithm) {
        algorithmsManager.toggleAlgorithmForLearning(algorithm)
        reload()
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
        .if(viewModel.algorithmIsLearning(algorithm.algorithm)) {
            $0.listRowBackground(Color.actualYellow)
        }
        .swipeActions {
            Button {
                viewModel.toggleAlgorithmForLearning(algorithm.algorithm)
            } label: {
                Image(systemName: "brain.fill")
            }
            .tint(viewModel.algorithmIsLearning(algorithm.algorithm) ? .gray : .actualYellow)
        }
    }
}

#Preview {
    ContentView(step: CFOPSolveStep.twoLookOLL)
}

private extension Color {
    static var actualYellow: Color {
        .init(uiColor: .yellow)
    }
}
