//
//  AlgorithmView.swift
//  Cubr2
//
//  Created by Dylan Elliott on 12/6/2025.
//

import DylKit
import SwiftUI

struct AlgorithmView<InnerContent: View>: View {
    let algorithm: AlgorithmWithMethod
    let bestTime: SolveTime?
    let content: () -> InnerContent
    
    let iconTapped: () -> Void
    
//    var stepsString: String { algorithm.defaultStepsString }
//    var steps: [String] { algorithm.defaultSteps}
    
    init(
        algorithm: AlgorithmWithMethod,
        bestTime: SolveTime?,
        content: @escaping () -> InnerContent,
        iconTapped: @escaping () -> Void,
        showTimes: AlgorithmWithMethod? = nil
    ) {
        self.algorithm = algorithm
        self.bestTime = bestTime
        self.iconTapped = iconTapped
        self.showTimes = showTimes
        self.content = content
    }
    
    @State var showTimes: AlgorithmWithMethod?
    
    var body: some View {
        contentView
            .sheet(item: $showTimes) { showTimeAlgorithm in
                NavigationStack {
                    TimesView(timeable: .algorithm(algorithm))
                }
            }
    }
    
    var contentView: some View {
        VStack {
            header
            rowBody
        }
    }
    
    private var header: some View {
        VStack {
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
                            Text(bestTime.string)
                        }
                    }
                }
            }
            
            if let description = algorithm.description {
               Text(description)
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
            
            content()
            
            Spacer()
        }
    }
}

extension AlgorithmView {
    init(
        algorithm: AlgorithmWithMethod,
        bestTime: SolveTime?,
        mnemonics: @escaping (String) -> [StepMnemonic],
        iconTapped: @escaping () -> Void,
        mnemonicsUpdated: (([StepMnemonic], String) -> Void)?,
        showTimes: AlgorithmWithMethod? = nil
    ) where InnerContent == AlgorithmStepsView {
        self.init(algorithm: algorithm, bestTime: bestTime, content: {
            AlgorithmStepsView(
                steps: algorithm.defaultSteps,
                mnemonics: mnemonics(algorithm.defaultStepsString),
                updateMnemonic: mnemonicsUpdated.map { mnemonicsUpdated in
                    { id, new in
                        var newMnemonics = mnemonics(algorithm.defaultStepsString)
                        
                        let index = newMnemonics.firstIndex(where: { $0.id == id})
                        
                        if let index = newMnemonics.firstIndex(where: { $0.id == id}), let new {
                            newMnemonics[index] = new
                        }else if let new {
                            newMnemonics.append(new)
                        } else if let index {
                            newMnemonics.remove(at: index)
                        }
                        
                        mnemonicsUpdated(newMnemonics, algorithm.defaultStepsString)
                    }
                }
            )
        }, iconTapped: iconTapped, showTimes: showTimes)
    }
}
