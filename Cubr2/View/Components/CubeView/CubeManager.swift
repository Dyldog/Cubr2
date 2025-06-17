import SceneKit
import SwiftUI

// MARK: – Cubie Data Model
class Cubie {
    let id = UUID()
    let node: SCNNode
    var logicalPosition: (x: Int, y: Int, z: Int)
    let solvedPosition: (x: Int, y: Int, z: Int)
    var netRotation: SCNQuaternion
    
    init(node: SCNNode, position: (x: Int, y: Int, z: Int)) {
        self.node = node
        self.logicalPosition = position
        self.solvedPosition = position
        self.netRotation = SCNQuaternion(0, 0, 0, 1)
    }
}

// MARK: – Cube Moves
enum CubeMove: String, CaseIterable {
    case U
    case UPrime
    case D
    case DPrime
    case L
    case LPrime
    case R
    case RPrime
    case F
    case FPrime
    case B
    case BPrime
    case M
    case MPrime
    
    var axis: SCNVector3 {
        switch self {
        case .U, .UPrime, .D, .DPrime:
            return SCNVector3(0, 1, 0)
        case .L, .LPrime, .R, .RPrime, .M, .MPrime:
            return SCNVector3(1, 0, 0)
        case .F, .FPrime, .B, .BPrime:
            return SCNVector3(0, 0, 1)
        }
    }
    
    var angle: Float {
        switch self {
        case .U, .DPrime, .LPrime, .R, .F, .BPrime, .MPrime:
            return -Float.pi / 2
        case .UPrime, .D, .L, .RPrime, .FPrime, .B, .M:
            return Float.pi / 2
        }
    }
    
    var affectedLayer: (axis: String, value: Int) {
        switch self {
        case .U, .UPrime:
            return ("y", 1)
        case .D, .DPrime:
            return ("y", -1)
        case .L, .LPrime:
            return ("x", -1)
        case .M, .MPrime:
            return ("x", 0)
        case .R, .RPrime:
            return ("x", 1)
        case .F, .FPrime:
            return ("z", 1)
        case .B, .BPrime:
            return ("z", -1)
        }
    }
    
    func rotateCoordinate(_ coord: (x: Int, y: Int, z: Int)) -> (x: Int, y: Int, z: Int) {
        switch self {
        case .U:
            return (x: coord.z, y: coord.y, z: -coord.x)
        case .UPrime:
            return (x: -coord.z, y: coord.y, z: coord.x)
        case .D:
            return (x: -coord.z, y: coord.y, z: coord.x)
        case .DPrime:
            return (x: coord.z, y: coord.y, z: -coord.x)
        case .L, .M:
            return (x: coord.x, y: coord.z, z: -coord.y)
        case .LPrime, .MPrime:
            return (x: coord.x, y: -coord.z, z: coord.y)
        case .R:
            return (x: coord.x, y: -coord.z, z: coord.y)
        case .RPrime:
            return (x: coord.x, y: coord.z, z: -coord.y)
        case .F:
            return (x: coord.y, y: -coord.x, z: coord.z)
        case .FPrime:
            return (x: -coord.y, y: coord.x, z: coord.z)
        case .B:
            return (x: -coord.y, y: coord.x, z: coord.z)
        case .BPrime:
            return (x: coord.y, y: -coord.x, z: coord.z)
        }
    }
    
    var quaternion: SCNQuaternion {
        let halfAngle = angle / 2
        let sinHalf = sin(halfAngle)
        let cosHalf = cos(halfAngle)
        let a = axis
        return SCNQuaternion(a.x * sinHalf, a.y * sinHalf, a.z * sinHalf, cosHalf)
    }
    
    var inverse: CubeMove {
        switch self {
        case .U: return .UPrime
        case .UPrime: return .U
        case .M: return .MPrime
        case .MPrime: return .M
        case .D: return .DPrime
        case .DPrime: return .D
        case .L: return .LPrime
        case .LPrime: return .L
        case .R: return .RPrime
        case .RPrime: return .R
        case .F: return .FPrime
        case .FPrime: return .F
        case .B: return .BPrime
        case .BPrime: return .B
        }
    }
}

// MARK: – CubeManager
class CubeManager: ObservableObject {
    let scene: SCNScene
    let cubeContainer: SCNNode   // Container node for the entire cube
    var cubies: [Cubie] = []
    let offset: Float = 1.1
    var moveHistory: [CubeMove] = []
    var isAnimating = false
    var unscrambleTimer: Timer?
    
    init(moves: [CubeMove]) {
        scene = SCNScene()
        cubeContainer = SCNNode()
        let cubeParent = SCNNode()
        cubeParent.addChildNode(cubeContainer)
        cubeContainer.rotation = .init(x: 0, y: 1, z: 0, w: .pi / 4.0)
        scene.rootNode.addChildNode(cubeParent)
        cubeParent.rotation = .init(x: 0, y: 0, z: -1, w: .pi / 4.0)
        setupCameraAndLights()
        buildCube()
        performMoves(moves)
    }
    
    private func setupCameraAndLights() {
        // Set up the camera at (7,7,7) with a look-at constraint.
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        let distance = 6
        cameraNode.position = SCNVector3(distance, 0, 0)
        let constraint = SCNLookAtConstraint(target: cubeContainer)
        constraint.isGimbalLockEnabled = true
        cameraNode.constraints = [constraint]
        scene.rootNode.addChildNode(cameraNode)
        
        // Add an omni light.
        let omniLight = SCNNode()
        omniLight.light = SCNLight()
        omniLight.light?.type = .omni
        omniLight.position = SCNVector3(0, distance, distance)
        scene.rootNode.addChildNode(omniLight)
        
        // Add ambient light.
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor.white
        scene.rootNode.addChildNode(ambientLight)
    }
    
    private func buildCube() {
        // Build the 3×3×3 cube with a chamfer.
        for x in -1...1 {
            for y in -1...1 {
                for z in -1...1 {
                    let box = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.05)
                    let front = SCNMaterial(); front.diffuse.contents = UIColor.red
                    let right = SCNMaterial(); right.diffuse.contents = UIColor.blue
                    let back  = SCNMaterial(); back.diffuse.contents = UIColor.orange
                    let left  = SCNMaterial(); left.diffuse.contents = UIColor.green
                    let top   = SCNMaterial(); top.diffuse.contents = UIColor.white
                    let bottom = SCNMaterial(); bottom.diffuse.contents = UIColor.yellow
                    box.materials = [front, right, back, left, top, bottom]
                    
                    let cubieNode = SCNNode(geometry: box)
                    cubieNode.position = SCNVector3(Float(x) * offset,
                                                    Float(y) * offset,
                                                    Float(z) * offset)
                    cubeContainer.addChildNode(cubieNode)
                    let cubie = Cubie(node: cubieNode, position: (x, y, z))
                    cubies.append(cubie)
                }
            }
        }
    }
    
    private func updateCubieTransform(_ cubie: Cubie) {
        let newPos = SCNVector3(Float(cubie.logicalPosition.x) * offset,
                                Float(cubie.logicalPosition.y) * offset,
                                Float(cubie.logicalPosition.z) * offset)
        cubie.node.position = newPos
        cubie.node.orientation = cubie.netRotation
    }
    
    // MARK: – Move Execution
    @MainActor
    func performMove(_ move: CubeMove, record: Bool = true, duration: Double = 2) async {
        guard !isAnimating else { return }
        isAnimating = true
        
        let layer = move.affectedLayer
        let affectedCubies = cubies.filter { cubie in
            switch layer.axis {
            case "x": return cubie.logicalPosition.x == layer.value
            case "y": return cubie.logicalPosition.y == layer.value
            case "z": return cubie.logicalPosition.z == layer.value
            default: return false
            }
        }
        
        let groupNode = SCNNode()
        cubeContainer.addChildNode(groupNode)
        for cubie in affectedCubies {
            cubie.node.removeFromParentNode()
            groupNode.addChildNode(cubie.node)
        }
        
        let rotationAction = SCNAction.rotate(by: CGFloat(move.angle), around: move.axis, duration: duration)
        await groupNode.runAction(rotationAction)
        for cubie in affectedCubies {
            cubie.logicalPosition = move.rotateCoordinate(cubie.logicalPosition)
            let oldQuat = cubie.netRotation
            let moveQuat = move.quaternion
            cubie.netRotation = multiplyQuaternion(q1: moveQuat, q2: oldQuat)
            
            let worldTransform = cubie.node.worldTransform
            cubie.node.transform = cubeContainer.convertTransform(worldTransform, from: nil)
            cubeContainer.addChildNode(cubie.node)
            updateCubieTransform(cubie)
        }
        groupNode.removeFromParentNode()
        if record { self.moveHistory.append(move) }
        self.isAnimating = false
    }
    
    private func multiplyQuaternion(q1: SCNQuaternion, q2: SCNQuaternion) -> SCNQuaternion {
        q1 * q2
    }
    
    // MARK: – Scramble & Solve
    func performMoves(_ moves: [CubeMove]) {
        Task {
            for move in moves {
                await performMove(move, duration: 2)
            }
        }
    }
    
    func isSolved() -> Bool {
        let tolerance: Float = 0.001
        for cubie in cubies {
            if cubie.logicalPosition != cubie.solvedPosition {
                return false
            }
            let q = cubie.netRotation
            if abs(q.x) > tolerance || abs(q.y) > tolerance || abs(q.z) > tolerance || abs(q.w - 1) > tolerance {
                return false
            }
        }
        return true
    }
}

