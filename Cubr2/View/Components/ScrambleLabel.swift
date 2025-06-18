//
//  ScrambleLabel.swift
//  Cubr2
//
//  Created by Dylan Elliott on 18/6/2025.
//

import DylKit
import SwiftUI

struct ScrambleLabel: View {
    let scramble: [String]
    let fontSize: CGFloat
    
    init(scramble: [String], fontSize: CGFloat = 28) {
        self.scramble = scramble
        self.fontSize = fontSize
    }
    
    var body: some View {
        WrappingHStack(verticalSpacing: 6) {
            ForEach(scramble.moves(chunk: 4)) { steps in
                MnemonicButton(
                    text: steps.joined(separator: " "),
                    highlighted: false,
                    onTap: { }
                )
                .font(.system(size: fontSize))
            }
        }
    }
}
