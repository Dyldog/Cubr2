//
//  HintsView.swift
//  Cubr2
//
//  Created by Dylan Elliott on 24/6/2025.
//

import SwiftUI

struct HintsView: View {
    @ObservedObject var algorithmsManager: AlgorithmsManager = .shared
    @State var algorithm: Algorithm?
    
    var algorithms: [AlgorithmWithMethod] {
        algorithmsManager.methodsEnabled.allAlgorithms().flatMap { $0.1 }
    }
    
    var body: some View {
        content
            .navigationTitle(algorithm?.name ?? "Hints")
            .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private var content: some View {
        if let algorithm {
            hintView(for: algorithm)
        } else {
            hintsList
        }
    }
    
    var hintsList: some View {
        LazyVGrid(columns: [.init(.flexible())].repeated(5)) {
            ForEach(algorithms) { algorithm in
                Button {
                    self.algorithm = algorithm.algorithm
                } label: {
                    Image(uiImage: algorithm.image)
                        .resizable()
                        .scaledToFit()
                }
            }
        }
        .padding(.horizontal)
    }
    
    func hintView(for algorithm: Algorithm) -> some View {
        VStack {
            Spacer()
            
            Image(uiImage: algorithm.image)
                .resizable()
                .scaledToFit()
                .frame(width: 200)
            
            AlgorithmStepsView(
                steps: algorithm.defaultSteps,
                mnemonics: algorithmsManager.mnemonics(for: algorithm.defaultStepsString),
                updateMnemonic: nil
            )
            .padding([.horizontal, .bottom])
            
            Spacer()
        }
    }
}
