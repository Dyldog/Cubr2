//
//  ContentView.swift
//  Cubr2
//
//  Created by Dylan Elliott on 10/6/2025.
//

import SwiftUI

class ContentViewModel: ObservableObject, MnemonicsHandling {
    private let step: SolveStep
    
    let algorithmsManager: AlgorithmsManager = .init()
    
    @Published private(set) var algorithms: [AlgorithmGroup] = []
    @Published var showScramble: Algorithm?
    
    var title: String { step.title }
    
    init(step: SolveStep) {
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
}

struct ContentView: View {
    
    @StateObject var viewModel: ContentViewModel
    
    init(step: SolveStep) {
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
                ScrambleView(algorithm: algorithm)
            }
        }
    }
    
    private func group(_ group: AlgorithmGroup) -> some View {
        Section {
            ForEach(group.algorithms, id: \.self) {
                algorithm($0)
            }
        } header: {
            Text(group.name)
                .bold()
                .font(.largeTitle)
        }
    }
    
    private func algorithm(_ algorithm: Algorithm) -> some View {
        AlgorithmView(algorithm: algorithm, mnemonicsHandler: viewModel) {
            viewModel.showScramble = algorithm
        }
        .if(viewModel.algorithmIsLearning(algorithm)) {
            $0.listRowBackground(Color.actualYellow)
        }
        .swipeActions {
            Button {
                viewModel.toggleAlgorithmForLearning(algorithm)
            } label: {
                Image(systemName: "brain.fill")
            }
            .tint(viewModel.algorithmIsLearning(algorithm) ? .gray : .actualYellow)
        }
    }
}

#Preview {
    ContentView(step: .twoLookOLL)
}

private extension Color {
    static var actualYellow: Color {
        .init(uiColor: .yellow)
    }
}
