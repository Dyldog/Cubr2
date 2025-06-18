//
//  TimerView.swift
//  Cubr2
//
//  Created by Dylan Elliott on 18/6/2025.
//

import SwiftUI

struct TimerView<T: BestTimeManaging>: View {
    @ObservedObject var viewModel: T
    let iconFont: Font = .system(size: 24)

    var body: some View {
        HStack {
            if viewModel.isTimerRunning {
                Button(systemName: "stop.fill") {
                    viewModel.stopTapped()
                }
                .font(iconFont)
            } else if viewModel.canReset {
                Button(systemName: "arrow.counterclockwise.circle.fill") {
                    viewModel.resetTapped()
                }
                .font(iconFont)
            } else {
                Button(systemName: "play.fill") {
                    viewModel.startTapped()
                }
                .font(iconFont)
            }
            
            Spacer()
            
            timeLabels
                .foregroundStyle(Color.accentColor)
                .bold()
            
            Spacer()
            
            if viewModel.isTimerRunning {
                Button(systemName: "xmark.app.fill") {
                    viewModel.cancelTapped()
                }
                .font(iconFont)
            } else {
                Button(systemName: "clock.fill") {
                    viewModel.showTimesTapped()
                }
                .font(iconFont)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 40).stroke(Color.accentColor, lineWidth: 3)
        }
        .padding([.bottom, .horizontal])
    }
    
    private var timeLabels: some View {
        VStack {
            if let currentTimeString = viewModel.currentTimeString {
                Text("Current: \(currentTimeString)")
            }
            
            if let bestTime = viewModel.bestTimeString {
                Text("PB: \(bestTime)")
            } else {
                Text("PB: None")
            }
        }
    }
}
