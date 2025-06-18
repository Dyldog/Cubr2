//
//  ScrambleView.swift
//  Cubr2
//
//  Created by Dylan Elliott on 11/6/2025.
//

import DylKit
import SwiftUI

class ScrambleViewModel: ObservableObject, MnemonicsHandling {
    let algorithm: AlgorithmWithMethod
    let algorithmsManager: AlgorithmsManager
    
    var title: String { algorithm.name }
    var steps: [String] { algorithm.defaultSteps }
    var scramble: [String]
    var mnemonics: [StepMnemonic] { algorithmsManager.mnemonics(for: algorithm.defaultStepsString) }
    var hintItems: [AlgorithmStepsView.Item] = []
    var hasExtraFullHint: Bool = false
    
    @Published var showImage: Bool = true
    let show3dCube: Bool = false
    @Published var hintCount: Int = 0
    @Published var showExtraFullHint: Bool = false
    @Published var showRemainingSteps: Bool = false
    
    var showRemainingStepsButton: Bool {
        guard 
            let lastStep = algorithm.method.steps.last,
            let lastGroup = algorithmsManager.algorithms(for: lastStep).last
        else { return false }
        
        return lastGroup.algorithms.contains { $0 == algorithm.algorithm } == false
        
    }
    
    var image: UIImage? {
        showImage ? algorithm.image : nil
    }
    
    init(
        algorithm: AlgorithmWithMethod,
        scramble: [String]?,
        algorithmsManager: AlgorithmsManager = .shared) {
        self.algorithm = algorithm
        self.scramble = scramble ?? algorithm.scrambles.first!.components(separatedBy: " ")
        self.algorithmsManager = algorithmsManager
        reload()
    }
    
    func reload() {
        let mnemonics = self.mnemonics
        hintItems = algorithm.defaultSteps.algorithmItems(with: mnemonics)
        hasExtraFullHint = !mnemonics.isEmpty
        showExtraFullHint = false
    }
    
    func showNextHint() {
        if showImage == false {
            showImage = true
        } else if hintCount == hintItems.count {
            showExtraFullHint.toggle()
        } else {
            hintCount = hintCount + 1 // Increment
//            showExtraFullHint = hasExtraFullHint && hintCount > hintItems.count // Check it while it's over
            hintCount = min(hintItems.count, hintCount) // Reset back
        }
    }
    
    func showFullHint() {
        showImage = true
        hintCount = hintItems.count
//        showExtraFullHint = hasExtraFullHint
    }
    
    func showRemainingStepsTapped() {
        showRemainingSteps = true
    }
}

struct ScrambleView: View {

    @StateObject var viewModel: ScrambleViewModel
    
    init(algorithm: AlgorithmWithMethod, scramble: [String]?) {
        _viewModel = .init(wrappedValue: .init(
            algorithm: algorithm,
            scramble: scramble
        ))
    }
    
    var body: some View {
        VStack {
            cubeView
                .aspectRatio(1, contentMode: .fit)
                .frame(minWidth: 150, maxWidth: 250)
//                .onTapGesture {
//                    viewModel.showNextHint()
//                }
//                .onLongPressGesture {
//                    viewModel.showFullHint()
//                }
            
            Text("Scramble")
                .bold()
                .padding(.bottom, 4)
            
            WrappingHStack(verticalSpacing: 6) {
                ForEach(viewModel.scramble.moves(chunk: 4)) { steps in
                    MnemonicButton(text: steps.joined(separator: " "), highlighted: false, onTap: { })
                        .font(.system(size: 28))
                }
            }
            
            hintView
                .padding([.horizontal, .top])
            
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
//        .toolbar {
//            Button(systemName: "wand.and.stars") {
//                viewModel.showNextHint()
//            }
//        }
        .sheet(isPresented: $viewModel.showRemainingSteps) {
            NavigationStack {
                TutorialView(algorithm: viewModel.algorithm)
            }
        }
    }
    
    @ViewBuilder
    private var cubeView: some View {
        if viewModel.show3dCube {
            CubeView(steps: viewModel.scramble.cubeMoves)
        } else if let image = viewModel.image {
            Image(image: image)
        }
    }
    
    @ViewBuilder
    private var hintView: some View {
        VStack {
            HStack {
                Text("Hint")
                    .bold()
                    .padding(.bottom, 4)
                
                Button(systemName: "eye.fill") {
                    viewModel.showNextHint()
                }
            }
            
            if viewModel.hintCount > 0 {
                AlgorithmStepsView(
                    steps: viewModel.steps,
                    mnemonics: viewModel.showExtraFullHint ? [] : viewModel.mnemonics,
                    shownItems: (0 ..<  (viewModel.showExtraFullHint ? viewModel.steps.count : viewModel.hintCount)),
                    updateMnemonic: nil
                )
            }
            
//            if viewModel.showExtraFullHint {
//                AlgorithmStepsView(
//                    steps: viewModel.steps,
//                    mnemonics: [],
//                    updateMnemonic: nil
//                )
//                .minimumScaleFactor(0.7)
//                .padding(.top, 4)
//            }
        }
    }
}
