//
//  LearnTestView.swift
//  Cubr2
//
//  Created by Dylan Elliott on 24/6/2025.
//

import DylKit
import SwiftUI

class LearnTestViewModel: ObservableObject, PracticesHandling {
    @Published var algorithmsManager: AlgorithmsManager = .shared
    
    @Published var algorithm: AlgorithmWithMethod!
    @Published private(set) var learningEvents: [LearningEvent] = []
    @Published private(set) var hintUsed: Bool = false
    
    @Published var alert: DylKit.Alert?

    var countForLearned: Int = 0
    
    var image: UIImage { algorithm.image }
    var scramble: [String] { algorithm.algorithm.scrambles.first ?? [] }
    
    var hasLearningAlgorithms: Bool {
        algorithmsManager.learningAlgorithms.isEmpty == false
    }
    
    private var hasLearnedAlgorithm: Bool {
        algorithmsManager
            .allLearningEvents(for: algorithm.algorithm)
            .sorted { $0.key < $1.key }
            .map { $0.value }
            .joined()
            .suffix(LearningEvent.countForMoveToLearned) 
        == [.success].repeated(LearningEvent.countForMoveToLearned)
    }
    
    var completedTests: [(AlgorithmWithMethod, [PracticesHandling.Label])] { labels(for: .today) }
    
    init() {
        countForLearned = LearningEvent.countForLearned
        loadTest()
    }
    
    func loadTest() {
        algorithm = algorithmsManager.testAlgorithms(countForLearned: countForLearned).randomElement()
        learningEvents = (algorithm?.algorithm).map { algorithmsManager.learningEvents(for: $0) } ?? []
        hintUsed = false
    }
    
    func hintRevealed() {
        hintUsed = true
    }
    
    func didProgressLearning(success: Bool) {
        learningEvents.append(success.learningEvent(usedHint: hintUsed))
        algorithmsManager.updateLearningEvents(for: algorithm.algorithm, to: learningEvents)
        hintUsed = false
    }
    
    func nextTapped() {
        if hasLearnedAlgorithm {
            alert = .init(
                title: "Looks like you've learned this algorithm",
                message: "Do you want to mark it as learned?",
                primaryAction: ("Yes", { [weak self] in
                    guard let self else { return }
                    algorithmsManager.markAlgorithmForLearning(algorithm.algorithm, status: .learned)
                    loadTest()
                }),
                secondaryAction: ("No", { [weak self] in
                    guard let self else { return }
                    loadTest()
                })
            )
        } else {
            loadTest()
        }
    }
    
    func keepLearningTapped() {
        countForLearned = LearningEvent.nextCountForLearned(after: algorithmsManager.maxLearnedCountForToday)
        loadTest()
    }
    
    func learnedTapped() {
        algorithmsManager.markAlgorithmForLearning(algorithm.algorithm, status: .learned)
        loadTest()
    }
    
    func reload() {
        guard let algorithm,
              algorithmsManager.testAlgorithms(countForLearned: countForLearned).contains(algorithm)
        else { return loadTest() }
        
        learningEvents = algorithmsManager.learningEvents(for: algorithm.algorithm)
    }
}

struct LearnTestView: View {
    @StateObject var viewModel: LearnTestViewModel = .init()
    
    var body: some View {
        VStack(spacing: 0) {
            if let algorithm = viewModel.algorithm {
                ScrambleView(
                    algorithm: algorithm,
                    scramble: viewModel.scramble,
                    hideScramble: true,
                    show3dCube: false,
                    onHintRevealed: {
                        viewModel.hintRevealed()
                    }
                )
                .id(viewModel.learningEvents)
                
                LearningProgressView(events: viewModel.learningEvents, maxCount: viewModel.countForLearned) {
                    viewModel.didProgressLearning(success: true)
                } onFail: {
                    viewModel.didProgressLearning(success: false)
                } onNext: {
                    viewModel.nextTapped()
                }
            } else {
                emptyView
            }
        }
        .alert($viewModel.alert)
        .onAppear {
            viewModel.reload()
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 24) {
            Text(
                viewModel.hasLearningAlgorithms
                ? "All practices completed for today"
                : "Add some algorithms to learn in the 'All' tab"
            )
            .font(.largeTitle)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
            
            if viewModel.hasLearningAlgorithms {
                Button("Keep Learning?") {
                    viewModel.keepLearningTapped()
                }
                .bold()
                
                ScrollView {
                    VStack() {
                        ForEach(viewModel.completedTests) { (algorithm, labels) in
                            PracticeRow(
                                algorithm: algorithm,
                                labels: labels
                            )
                        }
                    }
                    .padding()
                    .padding(.horizontal)
                }
            }
        }
    }
}

extension Bool {
    func learningEvent(usedHint: Bool) -> LearningEvent {
        switch self {
        case true: usedHint ? .successWithHint : .success
        case false: .fail
        }
    }
}
