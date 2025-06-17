//
//  ScrambleView.swift
//  Cubr2
//
//  Created by Dylan Elliott on 11/6/2025.
//

import SwiftUI

class ScrambleViewModel: ObservableObject, MnemonicsHandling {
    let algorithm: Algorithm
    let algorithmsManager: AlgorithmsManager
    
    var title: String { algorithm.name }
    var steps: [String] { algorithm.defaultSteps }
    var scramble: String { algorithm.scrambles.first ?? "NO SCRAMBLE!" }
    var mnemonics: [StepMnemonic] { algorithmsManager.mnemonics(for: algorithm.defaultStepsString) }
    var hintItems: [AlgorithmStepsView.Item] = []
    var hasExtraFullHint: Bool = false
    
    @Published var showImage: Bool = false
    @Published var hintCount: Int = 0
    @Published var showExtraFullHint: Bool = false
    
    var image: UIImage? {
        showImage ? algorithm.image : nil
    }
    
    init(algorithm: Algorithm, algorithmsManager: AlgorithmsManager = .shared) {
        self.algorithm = algorithm
        self.algorithmsManager = algorithmsManager
        reload()
    }
    
    func reload() {
        let mnemonics = self.mnemonics
        hintItems = algorithm.defaultSteps.algorithmItems(with: mnemonics)
        hasExtraFullHint = !mnemonics.isEmpty
    }
    
    func showNextHint() {
        if showImage == false {
            showImage = true
        } else {
            hintCount = hintCount + 1 // Increment
            showExtraFullHint = hasExtraFullHint && hintCount > hintItems.count // Check it while it's over
            hintCount = min(hintItems.count, hintCount) // Reset back
        }
    }
    
    func showFullHint() {
        showImage = true
        hintCount = hintItems.count
        showExtraFullHint = hasExtraFullHint
    }
}

struct ScrambleView: View {

    @StateObject var viewModel: ScrambleViewModel
    
    init(algorithm: Algorithm) {
        _viewModel = .init(wrappedValue: .init(algorithm: algorithm))
    }
    
    var body: some View {
        VStack {
            Text("Scramble")
                .bold()
            Text(viewModel.scramble)
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.5)
            
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250)
                    .onTapGesture {
                        viewModel.showNextHint()
                    }
                    .onLongPressGesture {
                        viewModel.showFullHint()
                    }
            }
            
            if viewModel.hintCount > 0 {
                hintView
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle(viewModel.title)
        .toolbar {
            Button(systemName: "wand.and.stars") {
                viewModel.showNextHint()
            }
        }
    }
    
    @ViewBuilder
    private var hintView: some View {
        Text("Hint")
            .bold()
        AlgorithmStepsView(
            steps: viewModel.steps,
            mnemonics: viewModel.mnemonics,
            shownItems: (0 ..< viewModel.hintCount),
            updateMnemonic: nil
        )
        
        if viewModel.showExtraFullHint {
            AlgorithmStepsView(
                steps: viewModel.steps,
                mnemonics: [],
                updateMnemonic: nil
            )
            .padding(.top, 4)
        }
    }
}
