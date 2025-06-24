//
//  StepButton.swift
//  Cubr2
//
//  Created by Dylan Elliott on 14/6/2025.
//

import SwiftUI

struct StepButton: View {
    let step: String
    let highlighted: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            Text(step)
                .font(.system(size: 34))
        }
        .buttonStyle(.plain)
        .if(highlighted) {
            $0.foregroundStyle(.lightBlue)
        }
    }
}
