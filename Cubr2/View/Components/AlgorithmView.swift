//
//  AlgorithmView.swift
//  Cubr2
//
//  Created by Dylan Elliott on 12/6/2025.
//

import DylKit
import SwiftUI

struct AlgorithmView: View {
    let algorithm: Algorithm
    let bestTime: Duration?
    let mnemonics: (String) -> [StepMnemonic]
    
    let iconTapped: () -> Void
    let mnemonicsUpdated: ([StepMnemonic], String) -> Void
    
    var stepsString: String { algorithm.defaultStepsString }
    var steps: [String] { algorithm.defaultSteps}
    
    var body: some View {
        HStack {
            Button {
                iconTapped()
            } label: {
                Image(uiImage: algorithm.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading) {
                HStack {
                    Text(algorithm.name)
                        .bold()
                    if let bestTime {
                        Text("PB: " + bestTime.formatted(.time(pattern: .minuteSecond(padMinuteToLength: 2, fractionalSecondsLength: 2))))
                    }
                }
                AlgorithmStepsView(
                    steps: steps,
                    mnemonics: mnemonics(stepsString)
                ) { id, new in
                    var newMnemonics = mnemonics(stepsString)
                    
                    let index = newMnemonics.firstIndex(where: { $0.id == id})
                    
                    if let index = newMnemonics.firstIndex(where: { $0.id == id}), let new {
                        newMnemonics[index] = new
                    }else if let new {
                        newMnemonics.append(new)
                    } else if let index {
                        newMnemonics.remove(at: index)
                    }
                    
                    mnemonicsUpdated(newMnemonics, stepsString)
                }
            }
            Spacer()
        }
    }
}
