//
//  Cubr2App.swift
//  Cubr2
//
//  Created by Dylan Elliott on 10/6/2025.
//

import SwiftUI

@main
struct Cubr2App: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationStack {
                    TestView()
                }.tabItem {
                    Label("Test", systemImage: "graduationcap.fill")
                }
                
                NavigationStack {
                    LearningView()
                }.tabItem {
                    Label("Learning", systemImage: "brain.fill")
                }
                
                NavigationStack {
                    StageList()
                }.tabItem {
                    Label("All", systemImage: "list.bullet")
                }
            }
        }
    }
}
