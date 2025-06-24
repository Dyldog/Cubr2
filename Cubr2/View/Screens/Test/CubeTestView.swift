//
//  CubeTestView.swift
//  Cubr2
//
//  Created by Dylan Elliott on 18/6/2025.
//

import DylKit
import SwiftUI

class CubeTestViewModel: BestTimeManaging {
    let algorithmsManager: AlgorithmsManager = .shared
    
    let forcedScramble: [String]?
    var scramble: [String] = []
    
    @Published var currentTime: Duration?
    @Published var currentHints: Int = 0
    @Published var currentTimer: Timer?
    
    @Published var showTimes: Bool = false
    @Published var showHint: Bool = false
    
    init(forcedScramble: [String]? = nil) {
        self.forcedScramble = forcedScramble
        loadTest()
    }
    
    func loadTest() {
        scramble = forcedScramble ?? String.randomMoves(12)
        currentHints = 0
    }
    
    var bestTime: SolveTime? {
        algorithmsManager.bestTime(for: .cube)
    }
    
    func saveTime(_ time: Duration, hints: Int) {
        algorithmsManager.addTime(time, with: hints, for: .cube, with: scramble)
    }
    
    func showHintTapped() {
        currentHints += 1
        showHint = true
    }
}

struct CubeTestView: View {
    @StateObject var viewModel: CubeTestViewModel = .init()
    
    var body: some View {
        BestTimeView(viewModel: viewModel) {
            VStack {
                Spacer()
                
                CubeView(steps: viewModel.scramble.cubeMoves, showResetButton: true)
                    .id(viewModel.scramble)
                
                ScrambleSection(scramble: viewModel.scramble, headerTrailing: {
                    Button(systemName: "questionmark.circle.fill") {
                        viewModel.showHintTapped()
                    }
                })
                .padding(.horizontal, 24)
                
                Spacer()
            }
        } times: {
            TimesView(timeable: .cube)
        }
        .sheet(isPresented: $viewModel.showHint) {
            NavigationStack {
                HintsView()
            }
            .presentationDetents([.medium])
        }
        .navigationTitle(TestMode.cube.title)

    }
}
