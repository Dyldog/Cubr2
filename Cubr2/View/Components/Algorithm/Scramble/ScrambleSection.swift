//
//  ScrambleSection.swift
//  Cubr2
//
//  Created by Dylan Elliott on 18/6/2025.
//

import SwiftUI

struct ScrambleSection: View {
    let scramble: [String]
    let hidesScramble: Bool
    @State var scrambleHidden: Bool
    
    init(scramble: [String], hidesScramble: Bool = false) {
        self.scramble = scramble
        self.hidesScramble = hidesScramble
        self.scrambleHidden = hidesScramble
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Scramble")
                    .bold()
                    .padding(.bottom, 4)
                
                if hidesScramble {
                    Button(systemName: "eye.fill") {
                        scrambleHidden.toggle()
                    }
                }
            }
            
            if !scrambleHidden {
                ScrambleLabel(scramble: scramble)
            }
        }
    }
}
