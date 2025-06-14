//
//  ScrambleView.swift
//  Cubr2
//
//  Created by Dylan Elliott on 11/6/2025.
//

import SwiftUI

struct ScrambleView: View {
    let algorithm: Algorithm
    
    var steps: [String] { algorithm.defaultSteps }
    
    @State var hintCount: Int = 0
    
    var hints: [String] {
        steps.prefix(hintCount).array
    }
    
    var body: some View {
        VStack {
            Image(uiImage: algorithm.image)
                .resizable()
                .scaledToFit()
                .frame(width: 250)
                .onTapGesture {
                    showNextHint()
                }
                .onLongPressGesture {
                    showFullHint()
                }
            
            Text("Scramble")
                .bold()
            Text(algorithm.scrambles.first ?? "NO SCRAMBLE!")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
            
            if !hints.isEmpty {
                hintsView
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle(algorithm.name)
    }
    
    private func showNextHint() {
        hintCount = min(steps.count, hintCount + 1)
    }
    
    private func showFullHint() {
        hintCount = steps.count
    }
    
    @ViewBuilder
    private var hintsView: some View {
        Text("Hint")
            .bold()
        hints.chunked(into: 8).stacked(.vertical) { chunk in
            chunk.stacked(.horizontal) { hint in
                Text(hint)
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
            }
        }
    }
}
