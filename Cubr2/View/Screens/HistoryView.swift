//
//  AllPracticesView.swift
//  Cubr2
//
//  Created by Dylan Elliott on 24/6/2025.
//

import DylKit
import SwiftUI

enum HistoryKind: CaseIterable, Pickable {
    case practices
    case times
    
    var title: String {
        switch self {
        case .practices: "Practices"
        case .times: "Times"
        }
    }
}

struct HistoryView: View {
    @State var display: HistoryKind = .practices
    
    var body: some View {
        content
            .toolbar {
                Picker("Displayed", selection: $display)
                    .pickerStyle(.menu)
                    .labelsHidden()
            }
    }
    
    @ViewBuilder
    private var content: some View {
        switch display {
        case .practices: PracticesView()
        case .times: AllTimesView()
        }
    }
}
