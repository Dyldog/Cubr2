//
//  TestView.swift
//  Cubr2
//
//  Created by Dylan Elliott on 18/6/2025.
//

import DylKit
import SwiftUI

enum TestMode: CaseIterable, Pickable {
    case algorithms
    case cube
    
    var title: String {
        switch self {
        case .cube: "Full Cube"
        case .algorithms: "Algorithms"
        }
    }
}

class TestViewModel: ObservableObject {
    @Published var mode: TestMode = .algorithms
}

struct TestView: View {
    @StateObject var viewModel: TestViewModel = .init()
    
    var body: some View {
        VStack {
            switch viewModel.mode {
            case .cube: CubeTestView()
            case .algorithms: LearnTestView() // AlgorithmTestView()
            }
        }
        .toolbar {
            Picker("Test Mode", selection: $viewModel.mode)
                .pickerStyle(.menu)
                .labelsHidden()
        }
    }
}


