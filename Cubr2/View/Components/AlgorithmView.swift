//
//  AlgorithmView.swift
//  Cubr2
//
//  Created by Dylan Elliott on 12/6/2025.
//

import DylKit
import SwiftUI

struct AlgorithmView: View {
    let algorithm: AlgorithmWithMethod
    let bestTime: Duration?
    let mnemonics: (String) -> [StepMnemonic]
    
    let iconTapped: () -> Void
    let mnemonicsUpdated: (([StepMnemonic], String) -> Void)?
    
    var stepsString: String { algorithm.defaultStepsString }
    var steps: [String] { algorithm.defaultSteps}
    
    @State var showTimes: AlgorithmWithMethod?
    
    var body: some View {
        content
            .sheet(item: $showTimes) { showTimeAlgorithm in
                NavigationStack {
                    TimesView(timeable: .algorithm(algorithm))
                }
            }
    }
    
    var content: some View {
        VStack {
            header
            rowBody
        }
    }
    
    private var header: some View {
        HStack {
            Text(algorithm.name)
                .bold()
            Spacer()
            
            if let bestTime {
                Button {
                    showTimes = algorithm
                } label: {
                    HStack {
                        Image(systemName: "star")
                        Text(bestTime.timeString)
                    }
                }
            }
        }
    }
    
    private var rowBody: some View {
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
            
            AlgorithmStepsView(
                steps: steps,
                mnemonics: mnemonics(stepsString),
                updateMnemonic: mnemonicsUpdated.map { mnemonicsUpdated in
                    { id, new in
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
            )
        }
    }
}
