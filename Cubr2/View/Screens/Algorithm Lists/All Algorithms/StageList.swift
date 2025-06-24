//
//  Stage List.swift
//  Cubr2
//
//  Created by Dylan Elliott on 10/6/2025.
//

import SwiftUI

struct StageList: View {
    @ObservedObject var algorithmsManager: AlgorithmsManager = .shared
    @State var showAllTimes: Bool = false
    @State var showMethods: Bool = false

    var body: some View {
        List(algorithmsManager.methodsEnabled, id: \.self) { method in
            Section(method.title) {
                ForEach(method.steps) { step in
                    NavigationLink {
                        ContentView(step: step)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(step.title)
                                .bold()
                                .font(.largeTitle)
                            
                            Text(description(for: step))
                        }
                    }

                }
            }
        }
        .navigationTitle("Algorithms")
        .toolbar {
            Button(systemName: "clock") {
                showAllTimes = true
            }
            
            Button(systemName: "eye") {
                showMethods = true
            }
            
        }
        .sheet(isPresented: $showAllTimes) {
            NavigationStack {
                HistoryView()
            }
        }
        .sheet(isPresented: $showMethods) {
            NavigationStack {
                MethodsView()
            }
        }
    }
    
    private func description(for step: any SolveStep) -> String {
        let algorithms = step.algorithm(with: algorithmsManager).algorithms { _, _, algorithm in
            algorithm
        }
        
        let counts = algorithms.map { algorithmsManager.algorithmLearningStatus($0) }.uniqueCount
        
        guard counts[.learning] != nil || counts[.learned] != nil else {
            return "\(algorithms.count) algorithms"
        }
        
        return [
            counts[.learning].map { "\($0) learning."},
            counts[.learned].map { "\($0) learned."},
            counts[nil].map { "\($0) not learning."}
        ]
        .compactMap { $0 }
        .joined(separator: " ")
    }
}
