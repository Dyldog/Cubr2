//
//  CubeView.swift
//  Cubr2
//
//  Created by Dylan Elliott on 17/6/2025.
//

import DylKit
import SceneKit
import SwiftUI

struct CubeView: View {
    @StateObject var cubeManager: CubeManager
    
    let showResetButton: Bool
    
    init(steps: [CubeMove], showResetButton: Bool = false) {
        _cubeManager = .init(wrappedValue: .init(moves: steps))
        self.showResetButton = showResetButton
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            SceneView(scene: cubeManager.scene, options: [.allowsCameraControl])
            
            if showResetButton {
                buttons
                    .padding(.horizontal, 30)
            }
        }
    }
    
    private var buttons: some View {
        HStack {
            Button(systemName: "arrow.triangle.2.circlepath") {
                cubeManager.resetAndAnimateScramble()
            }
            .imageScale(.large)
        }
    }
}
