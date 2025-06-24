//
//  MethodsView.swift
//  Cubr2
//
//  Created by Dylan Elliott on 17/6/2025.
//

import SwiftUI

struct MethodsView: View {
    @ObservedObject var algorithmsManager: AlgorithmsManager = .shared
    
    var body: some View {
        List(SolveMethod.allCases, id: \.self) { method in
            Button {
                rowTapped(for: method)
            } label: {
                HStack {
                    Text(method.title)
                        .font(.largeTitle)
                    
                    Spacer()
                    
                    if methodEnabled(method) {
                        Image(systemName: "checkmark")
                    }
                }
            }
            .buttonStyle(.plain)

        }
        .navigationTitle("Solve Methods")
    }
    
    private func methodEnabled(_ method: SolveMethod) -> Bool {
        algorithmsManager.methodEnabled(method)
    }
    
    private func rowTapped(for method: SolveMethod) {
        algorithmsManager.updateMethodEnabled(!methodEnabled(method), for: method)
    }
}
