//
//  TestView.swift
//  Cubr2
//
//  Created by Dylan Elliott on 17/6/2025.
//

import SwiftUI

class AlgorithmTestViewModel: BestTimeManaging {
    internal let algorithmsManager: AlgorithmsManager = .shared
    
    let forcedAlgorithm: AlgorithmWithMethod?
    @Published var algorithm: AlgorithmWithMethod!

    @Published var currentTimer: Timer?
    @Published var currentTime: Duration?
    @Published var currentHints: Int = 0
    
    @Published var showTimes: Bool = false
    
    var scramble: [String] { algorithm.algorithm.scrambles.first ?? [] }
    
    let loadFakeScrambles: Bool = false
    var fakeScrambles: [ScrambleData] = [
//        ["L L R R F F L L R R F F"],
//        ["L L R R F F"],
//        ["L L R R F F"],
        "L F L",
//        ["M"],
//        ["M'"],
//        ["U"],
//        ["U2"],
//        ["U'"],
//        ["D"],
//        ["D2"],
//        ["D'"],
//        ["L"],
//        ["L2"],
//        ["L'"],
//        ["R"],
//        ["R2"],
//        ["R'"],
//        ["r"],
//        ["r'"],
//        ["F"],
//        ["F2"],
//        ["F'"],
//        ["B"],
//        ["B2"],
//        ["B'"]
    ]
    
    init(forcedAlgorithm: AlgorithmWithMethod? = nil) {
        self.forcedAlgorithm = forcedAlgorithm
        loadTest()
    }
    
    func loadTest() {
        algorithm = forcedAlgorithm ?? algorithmsManager.learningAlgorithms
            .algorithms { method, _, _, algorithm in
                .init(method: method.method, algorithm: algorithm)
            }
            .randomElement()
        
        if loadFakeScrambles {
            algorithm = .init(method: algorithm.method, algorithm: .init(
                name: algorithm.name, 
                description: algorithm.algorithm.description,
                stepSets: algorithm.stepSets,
                scrambles: [fakeScrambles.removeFirst().scramble]
            ))
        }
    }
    
    var bestTime: SolveTime? {
        algorithmsManager.bestTime(for: .algorithm(algorithm))
    }

    
    func saveTime(_ time: Duration, hints: Int) {
        algorithmsManager.addTime(
            time,
            with: hints,
            for: .algorithm(algorithm),
            with: scramble
        )
    }
}

struct AlgorithmTestView: View {
    @StateObject var viewModel: AlgorithmTestViewModel = .init()
    
    var body: some View {
        BestTimeView(viewModel: viewModel) {
            ScrambleView(
                algorithm: viewModel.algorithm,
                scramble: viewModel.scramble
            )
            .id(viewModel.algorithm.algorithm)
        } times: {
            TimesView(timeable: .algorithm(viewModel.algorithm))
        }
    }
}
