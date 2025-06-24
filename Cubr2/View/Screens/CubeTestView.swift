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
    @Published var currentTimer: Timer?
    
    @Published var showTimes: Bool = false
    
    init(forcedScramble: [String]? = nil) {
        self.forcedScramble = forcedScramble
        loadTest()
    }
    
    func loadTest() {
        scramble = forcedScramble ?? String.randomMoves(12)
    }
    
    var bestTime: Duration? {
        algorithmsManager.bestTime(for: .cube)
    }
    
    func saveTime(_ time: Duration) {
        algorithmsManager.addTime(time, for: .cube, with: scramble)
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
                
                ScrambleSection(scramble: viewModel.scramble)
                    .padding(.horizontal, 24)
                
                Spacer()
            }
        } times: {
            TimesView(timeable: .cube)
        }
        .navigationTitle(TestMode.cube.title)

    }
}
