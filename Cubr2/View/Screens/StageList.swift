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
                        Text(step.title)
                            .bold()
                            .font(.largeTitle)
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
                AllTimesView()
            }
        }
        .sheet(isPresented: $showMethods) {
            NavigationStack {
                MethodsView()
            }
        }
    }
}
