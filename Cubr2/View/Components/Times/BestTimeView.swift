//
//  BestTimeView.swift
//  Cubr2
//
//  Created by Dylan Elliott on 18/6/2025.
//

import SwiftUI

struct BestTimeView<T: BestTimeManaging, Content: View, Times: View>: View {
    @ObservedObject var viewModel: T
    
    let content: () -> Content
    let times: () -> Times
    
    init(viewModel: T, content: @escaping () -> Content, times: @escaping () -> Times) {
        self.viewModel = viewModel
        self.content = content
        self.times = times
    }
    
    var body: some View {
        VStack {
            Spacer()
            content()
            Spacer()
            TimerView(viewModel: viewModel)
        }
        .toolbar {
            Button(systemName: "arrow.circlepath") {
                viewModel.resetTapped()
            }
        }
        .sheet(isPresented: $viewModel.showTimes) {
            NavigationStack {
                times()
            }
        }
    }
}
