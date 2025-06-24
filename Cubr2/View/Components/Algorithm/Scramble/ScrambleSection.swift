//
//  ScrambleSection.swift
//  Cubr2
//
//  Created by Dylan Elliott on 18/6/2025.
//

import SwiftUI

struct ScrambleSection<Trailing: View>: View {
    let scramble: [String]
    let hidesScramble: Bool
    let headerTrailing: (() -> Trailing)?
    @State var scrambleHidden: Bool
    
    init(scramble: [String], headerTrailing: @escaping () -> Trailing) {
        self.scramble = scramble
        self.hidesScramble = false
        self.scrambleHidden = hidesScramble
        self.headerTrailing = headerTrailing
    }
    
    init(scramble: [String], hidesScramble: Bool = false) where Trailing == EmptyView {
        self.scramble = scramble
        self.hidesScramble = hidesScramble
        self.scrambleHidden = hidesScramble
        self.headerTrailing = nil
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .firstTextBaseline) {
                Text("Scramble")
                    .bold()
                    .padding(.bottom, 4)
                
                if hidesScramble {
                    Button(systemName: "eye.fill") {
                        scrambleHidden.toggle()
                    }
                }
                
                headerTrailing?()
            }
            
            if !scrambleHidden {
                ScrambleLabel(scramble: scramble)
            }
        }
    }
}
