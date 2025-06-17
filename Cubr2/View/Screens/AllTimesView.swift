//
//  AllTimesView.swift
//  Cubr2
//
//  Created by Dylan Elliott on 17/6/2025.
//

import SwiftUI

struct AllTimesView: View {
    @ObservedObject var algorithmsManager: AlgorithmsManager = .shared
    var algorithms: [(String, [Algorithm])] { SolveMethod.allAlgorithmsWithTimes() }
    
    var body: some View {
        List {
            ForEach(algorithms) { group in
                Section(group.0) {
                    ForEach(group.1) { algorithm in
                        NavigationLink(value: algorithm) {
                            HStack {
                                Image(uiImage: algorithm.image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100)
                                
                                VStack(alignment: .leading) {
                                    Text(algorithm.name)
                                        .font(.largeTitle)
                                        .bold()
                                    
                                    HStack {
                                        Image(systemName: "star.fill")
                                        Text(bestTime(for: algorithm))
                                            .font(.largeTitle)
                                    }
                                    
                                    Text(attemptsString(for: algorithm))
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationDestination(for: Algorithm.self) { algorithm in
            TimesView(algorithm: algorithm)
        }
        .navigationTitle("All Times")
    }
    
    private func bestTime(for algorithm: Algorithm) -> String {
        algorithmsManager.bestTime(for: algorithm)?.timeString ?? ""
    }
    
    private func attemptsString(for algorithm: Algorithm) -> String {
        let attempts = algorithmsManager.attempts(for: algorithm).count
        return "\(attempts) \("Time".pluralise(attempts))"
    }
}

private extension SolveMethod {
    static func allAlgorithmsWithTimes(with algorithmsManager: AlgorithmsManager = .shared) -> [(String, [Algorithm])] {
        SolveMethod.allAlgorithms(with: algorithmsManager).map { title, algorithms in
            (title, algorithms.filter { algorithmsManager.attempts(for: $0).isEmpty == false })
        }
        .filter { $0.1.isEmpty == false }
    }
}
