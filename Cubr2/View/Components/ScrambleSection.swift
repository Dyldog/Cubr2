//
//  ScrambleSection.swift
//  Cubr2
//
//  Created by Dylan Elliott on 18/6/2025.
//

import SwiftUI

struct ScrambleSection: View {
    let scramble: [String]
    
    var body: some View {
        VStack {
            Text("Scramble")
                .bold()
                .padding(.bottom, 4)
            
            ScrambleLabel(scramble: scramble)
        }
    }
}
