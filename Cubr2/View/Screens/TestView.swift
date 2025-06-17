//
//  TestView.swift
//  Cubr2
//
//  Created by Dylan Elliott on 17/6/2025.
//

import SwiftUI

class TestViewModel: ObservableObject {
    private let algorithmsManager: AlgorithmsManager = .shared
    @Published var algorithm: Algorithm!

    @Published private var currentTimer: Timer?
    var isTimerRunning: Bool { currentTimer != nil }
    var canReset: Bool { currentTime != nil }
    
    @Published private var currentTime: Duration?
    
    var currentTimeString: String? {
        currentTime.map { formatDuration($0) }
    }
    
    private var bestTime: Duration? {
        algorithmsManager.bestTime(for: algorithm)
    }
    
    var bestTimeString: String? {
        bestTime.map { formatDuration($0) }
    }
    
    @Published var showTimes: Bool = false
    
    init() {
        loadAlgorithm()
    }
    
    private func loadAlgorithm() {
        algorithm = algorithmsManager.learningAlgorithms
            .flatMap { $0.1 }
            .flatMap { $0.algorithms }.randomElement()
    }
    
    private func formatDuration(_ duration: Duration) -> String {
        duration.timeString
    }
    
    private func startTimer() {
        currentTime = .zero
        
        currentTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            self.currentTime = (self.currentTime ?? .zero) + .seconds(timer.timeInterval)
        }
    }
    
    private func stopTimer() {
        currentTimer?.invalidate()
        currentTimer = nil
    }
    
    func startTapped() {
        startTimer()
    }
    
    func resetTapped() {
        stopTimer()
        loadAlgorithm()
        currentTime = nil
    }
    
    func stopTapped() {
        stopTimer()
        
        guard let currentTime else { return }
        
        objectWillChange.send()
        
        algorithmsManager.addTime(currentTime, for: algorithm)
    }
    
    func cancelTapped() {
        stopTimer()
        currentTime = nil
    }
    
    func showTimesTapped() {
        showTimes = true
    }
}

struct TestView: View {
    @StateObject var viewModel: TestViewModel = .init()
    
    let iconFont: Font = .system(size: 24)
    
    var body: some View {
        VStack {
            ScrambleView(algorithm: viewModel.algorithm)
                .id(viewModel.algorithm)
            timer
        }
        .toolbar {
            Button(systemName: "arrow.circlepath") {
                viewModel.resetTapped()
            }
        }
        .sheet(isPresented: $viewModel.showTimes) {
            NavigationStack {
                TimesView(algorithm: viewModel.algorithm)
            }
        }
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
    
    private var timer: some View {
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
}
