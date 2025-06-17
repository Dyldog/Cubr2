//
//  ScrambleView.swift
//  Cubr2
//
//  Created by Dylan Elliott on 11/6/2025.
//

import DylKit
import SwiftUI

class ScrambleViewModel: ObservableObject, MnemonicsHandling {
    let method: SolveMethod
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
    @Published var showRemainingSteps: Bool = false
    
    var showRemainingStepsButton: Bool {
        guard 
            let lastStep = method.steps.last,
            let lastGroup = algorithmsManager.algorithms(for: lastStep).last
        else { return false }
        
        return lastGroup.algorithms.contains(algorithm) == false
        
    }
    
    var image: UIImage? {
        showImage ? algorithm.image : nil
    }
    
    init(method: SolveMethod, algorithm: Algorithm, algorithmsManager: AlgorithmsManager = .shared) {
        self.method = method
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
    
    func showRemainingStepsTapped() {
        showRemainingSteps = true
    }
}

struct ScrambleView: View {

    @StateObject var viewModel: ScrambleViewModel
    
    init(method: SolveMethod, algorithm: Algorithm) {
        _viewModel = .init(wrappedValue: .init(method: method, algorithm: algorithm))
    }
    
    var body: some View {
        VStack {
            Text("Scramble")
                .bold()
                .padding(.bottom, 4)
            
            WrappingHStack(verticalSpacing: 6) {
                ForEach(viewModel.scramble.components(separatedBy: " ").moves(chunk: 4)) { steps in
                    MnemonicButton(text: steps.joined(separator: " "), highlighted: false, onTap: { })
                        .font(.system(size: 28))
                }
            }
            
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
            
            if viewModel.showRemainingStepsButton {
                Button("Remaining Steps") {
                    viewModel.showRemainingStepsTapped()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .navigationTitle(viewModel.title)
        .toolbar {
            Button(systemName: "wand.and.stars") {
                viewModel.showNextHint()
            }
        }
        .sheet(isPresented: $viewModel.showRemainingSteps) {
            NavigationStack {
                TutorialView(algorithm: viewModel.algorithm)
            }
        }
    }
    
    @ViewBuilder
    private var hintView: some View {
        Text("Hint")
            .bold()
            .padding(.bottom, 4)
        
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
