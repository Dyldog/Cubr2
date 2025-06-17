//
//  Stage List.swift
//  Cubr2
//
//  Created by Dylan Elliott on 10/6/2025.
//

import SwiftUI

struct StageList: View {
    @State var showAllTimes: Bool = false

    var body: some View {
        List(SolveStep.allCases, id: \.self) { step in
            NavigationLink(value: step) {
                Text(step.title)
                    .bold()
                    .font(.largeTitle)
            }
        }.navigationDestination(for: SolveStep.self) { step in
            ContentView(step: step)
        }
        .navigationTitle("Algorithms")
        .toolbar {
            Button(systemName: "clock") {
                showAllTimes = true
            }
        }
        .sheet(isPresented: $showAllTimes) {
            NavigationStack {
                AllTimesView()
            }
        }
    }
}
