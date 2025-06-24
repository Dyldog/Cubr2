//
//  TutorialView.swift
//  Cubr2
//
//  Created by Dylan Elliott on 17/6/2025.
//

import DylKit
import SwiftUI

class TutorialViewModel: ObservableObject, AlgorithmHandling {
    typealias Group = (title: String, algorithms: [AlgorithmWithMethod])
    let algorithmsManager: AlgorithmsManager = .shared
    
    private let allAlgorithms: [Group]
    @Published private var currentIndex = 0
    
    private var currentGroup: Group { allAlgorithms[currentIndex] }
    var title: String { currentGroup.title }
    var algorithms: [AlgorithmWithMethod] { currentGroup.algorithms }
    
    var isAtFirstStep: Bool {
        currentIndex == 0
    }
    
    var isAtLastStep: Bool {
        currentIndex == allAlgorithms.lastIndex
    }
    
    init(algorithm: AlgorithmWithMethod) {
        self.allAlgorithms = algorithm.method.allAlgorithms()
        self.currentIndex = (algorithm.method.allAlgorithms().firstIndex { _, algorithms in
            algorithms.contains(algorithm)
        } ?? -1) + 1
    }
    
    func previousTapped() {
        currentIndex = max(currentIndex - 1, 0)
    }
    
    func nextTapped() {
        currentIndex = min(currentIndex + 1, allAlgorithms.count - 1)
    }
    
    func reload() {}
}

struct TutorialView: View {
    
    @StateObject var viewModel: TutorialViewModel
    @Environment(\.dismiss) var dismiss
    
    init(algorithm: AlgorithmWithMethod) {
        _viewModel = .init(wrappedValue: .init(algorithm: algorithm))
    }
    
    var body: some View {
        List(viewModel.algorithms) { algorithm in
            AlgorithmView(
                algorithm: algorithm, handler: viewModel, disallowMmnemonicsUpdating: true, iconTapped: nil)
        }
        .listStyle(.plain)
        .navigationTitle(viewModel.title)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if viewModel.isAtFirstStep == false {
                    Button(systemName: "arrowshape.left.fill") {
                        viewModel.previousTapped()
                    }
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.isAtLastStep {
                    Button(systemName: "checkmark.circle.fill") {
                        dismiss()
                    }
                } else {
                    Button(systemName: "arrowshape.right.fill") {
                        viewModel.nextTapped()
                    }
                }
            }
        }
    }
}
