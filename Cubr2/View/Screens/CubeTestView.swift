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
                
                Text("Scramble")
                    .bold()
                    .padding(.bottom, 4)
                
                WrappingHStack(verticalSpacing: 6) {
                    ForEach(viewModel.scramble.moves(chunk: 4)) { steps in
                        MnemonicButton(
                            text: steps.joined(separator: " "),
                            highlighted: false,
                            onTap: { }
                        )
                        .font(.system(size: 28))
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
        } times: {
            TimesView(timeable: .cube)
        }
        .navigationTitle(TestMode.cube.title)

    }
}
