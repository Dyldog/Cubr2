//
//  TestView.swift
//  Cubr2
//
//  Created by Dylan Elliott on 18/6/2025.
//

import DylKit
import SwiftUI

enum TestMode: CaseIterable, Pickable {
    case learningAlgorithms
    case learningAndLearnedAlgorithms
    case cube
    
    var title: String {
        switch self {
        case .cube: "Full Cube"
        case .learningAlgorithms: "Learning Algorithms"
        case .learningAndLearnedAlgorithms: "Learning & Learned Algorithms"
        }
    }
}

class TestViewModel: ObservableObject {
    @Published var mode: TestMode = .learningAlgorithms
}

struct TestView: View {
    @StateObject var viewModel: TestViewModel = .init()
    @State var showDebug: Bool = false
    
    var body: some View {
        VStack {
            switch viewModel.mode {
            case .cube: CubeTestView()
            case .learningAlgorithms: LearnTestView() // AlgorithmTestView()
            case .learningAndLearnedAlgorithms: LearnTestView(includeLearned: true)
            }
        }
        .sheet(isPresented: $showDebug) {
            NavigationStack {
                CubeMoveList()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Picker("Test Mode", selection: $viewModel.mode)
                    .pickerStyle(.menu)
                    .labelsHidden()
            }
            
            ToolbarItem(placement: .topBarLeading) {
                Button(systemName: "ant.fill") {
                    showDebug = true
                }
            }
        }
    }
}


