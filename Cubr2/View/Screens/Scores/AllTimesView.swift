//
//  AllTimesView.swift
//  Cubr2
//
//  Created by Dylan Elliott on 17/6/2025.
//

import SwiftUI

struct AllTimesView: View {
    @ObservedObject var algorithmsManager: AlgorithmsManager = .shared
    
    var hasFullCubeTimes: Bool {
        algorithmsManager.attempts(for: .cube).isEmpty == false
    }
    
    var algorithms: [(String, [AlgorithmWithMethod])] {
        algorithmsManager.methodsEnabled.allAlgorithmsWithTimes()
    }
    
    @State var hideWithHints: Bool = false
    
    var body: some View {
        List {
            if hasFullCubeTimes {
                Section {
                    row(for: .cube)
                }
            }
            
            ForEach(algorithms) { group in
                Section(group.0) {
                    ForEach(group.1) { algorithm in
                        row(for: .algorithm(algorithm))
                    }
                }
            }
        }
        .toolbar {
            Button(systemName: hideWithHints ? "eye.slash.fill" : "eye.fill") {
                hideWithHints.toggle()
            }
        }
        .navigationDestination(for: Timeable.self) { timeable in
            TimesView(timeable: timeable, hideWithHints: hideWithHints)
        }
        .navigationTitle("All Times")
    }
    
    private func row(for timeable: Timeable) -> some View {
        NavigationLink(value: timeable) {
            HStack {
                Image(uiImage: timeable.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90)
                
                VStack(alignment: .leading) {
                    Text(timeable.name)
                        .font(.largeTitle)
                        .bold()
                    
                    HStack {
                        Image(systemName: "star.fill")
                        Text(bestTime(for: timeable))
                            .font(.largeTitle)
                    }
                    
                    Text(attemptsString(for: timeable))
                }
            }
        }
    }
    
    private func bestTime(for timeable: Timeable) -> String {
        let time = algorithmsManager.bestTime(for: timeable, withoutHints: hideWithHints)
        return time.map { hideWithHints ? $0.time.timeString : $0.string } ?? ""
    }
    
    private func attemptsString(for timeable: Timeable) -> String {
        let attempts = algorithmsManager.attempts(for: timeable).count
        return "\(attempts) \("Time".pluralise(attempts))"
    }
}

private extension Array where Element == SolveMethod {
    func allAlgorithmsWithTimes(with algorithmsManager: AlgorithmsManager = .shared) -> [(String, [AlgorithmWithMethod])] {
        allAlgorithms(with: algorithmsManager).map { title, algorithms in
            (title, algorithms.filter {
                algorithmsManager.attempts(for: .algorithm($0)).isEmpty == false
            })
        }
        .filter { $0.1.isEmpty == false }
    }
}
