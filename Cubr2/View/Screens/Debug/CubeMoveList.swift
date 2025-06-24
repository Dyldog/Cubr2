//
//  CubeMoveList.swift
//  Cubr2
//
//  Created by Dylan Elliott on 24/6/2025.
//

import DylKit
import SwiftUI

struct CubeMoveList: View {
    @State var index: Int = 0
    
    var move: String {
        String.allMoves[index]
    }
    
    var body: some View {
        HStack {
            Button(systemName: "arrow.left") {
                index = max(0, index - 1)
            }
            .imageScale(.large)
            .bold()
            
            VStack {
                CubeView(steps: move.cubeMoves, showResetButton: true)
                    .frame(height: 300)
                    .id(index)
                Text(move)
                    .bold()
                    .font(.largeTitle)
            }
            .padding()
            
            Button(systemName: "arrow.right") {
                index = min(String.allMoves.count - 1, index + 1)
            }
            .imageScale(.large)
            .bold()
        }
        .padding()
    }
}
