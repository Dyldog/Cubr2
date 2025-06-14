//
//  MnemonicButton.swift
//  Cubr2
//
//  Created by Dylan Elliott on 14/6/2025.
//

import SwiftUI

struct MnemonicButton: View {
    let text: String
    let highlighted: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            Text(text)
                .bold()
                .foregroundStyle(.white)
                .padding(.horizontal)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundStyle(highlighted ? .lightBlue : .blue)
                }
        }
        .buttonStyle(.plain)
    }
}
