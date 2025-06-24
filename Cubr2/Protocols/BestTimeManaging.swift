//
//  BestTimeManaging.swift
//  Cubr2
//
//  Created by Dylan Elliott on 18/6/2025.
//

import Combine
import SwiftUI

protocol BestTimeManaging: AnyObject, BestTimeHandling, ObservableObject
where Self.ObjectWillChangePublisher == ObservableObjectPublisher {
    var currentTime: Duration? { get set }
    var currentHints: Int { get set }
    var bestTime: SolveTime? { get }
    var currentTimer: Timer? { get set }
    var showTimes: Bool { get set}
    
    func loadTest()
    func saveTime(_ time: Duration, hints: Int)
}

extension BestTimeManaging {
    var isTimerRunning: Bool { currentTimer != nil }
    var canReset: Bool { currentTime != nil }
    
    var currentTimeString: String? {
        currentTime.map { $0.timeString }
    }
    
    var bestTimeString: String? {
        bestTime.map { "\($0.time.timeString) (\($0.hints))" }
    }
    
    private func startTimer() {
        currentTime = .zero
        currentHints = 0
        
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
        loadTest()
        currentTime = nil
        currentHints = 0
    }
    
    func stopTapped() {
        stopTimer()
        
        guard let currentTime else { return }
        
        objectWillChange.send()
        
        saveTime(currentTime, hints: currentHints)
    }
    
    func cancelTapped() {
        stopTimer()
        currentTime = nil
    }
    
    func showTimesTapped() {
        showTimes = true
    }
}
