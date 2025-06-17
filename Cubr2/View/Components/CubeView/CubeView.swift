//
//  CubeView.swift
//  Cubr2
//
//  Created by Dylan Elliott on 17/6/2025.
//

import SceneKit
import SwiftUI

struct CubeView: View {
    @StateObject var cubeManager: CubeManager
    
    init(steps: [CubeMove]) {
        _cubeManager = .init(wrappedValue: .init(moves: steps))
    }
    
    var body: some View {
        SceneView(scene: cubeManager.scene, options: [.allowsCameraControl])
    }
}
