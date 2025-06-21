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
    case E
    case EPrime
    case D
    case DPrime
    case L
    case LPrime
    case M
    case MPrime
    case R
    case RPrime
    case F
    case FPrime
    case S
    case SPrime
    case B
    case BPrime
    
    var axis: SCNVector3 {
        switch self {
        case .U, .UPrime: SCNVector3(0, -1, 0)
        case .D, .DPrime, .E, .EPrime: SCNVector3(0, 1, 0)
        case .L, .LPrime, .M, .MPrime: SCNVector3(1, 0, 0)
        case .R, .RPrime: SCNVector3(-1, 0, 0)
        case .F, .FPrime, .S, .SPrime: SCNVector3(0, 0, -1)
        case .B, .BPrime: SCNVector3(0, 0, 1)
        }
    }
    
    var angle: Float {
        switch self {
        case .U, .D, .L, .R, .F, .B, .E, .M, .S:
            return Float.pi / 2
        case .UPrime, .DPrime, .LPrime, .RPrime, .FPrime, .BPrime, .EPrime, .MPrime, .SPrime:
            return -Float.pi / 2
        }
    }
    
    var affectedLayer: (axis: String, value: Int) {
        switch self {
        case .U, .UPrime:
            return ("y", 1)
        case .E, .EPrime:
            return ("", 0)
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
        case .S, .SPrime:
            return ("", 0)
        case .B, .BPrime:
            return ("z", -1)
        }
    }
    
    func rotateCoordinate(_ coord: (x: Int, y: Int, z: Int)) -> (x: Int, y: Int, z: Int) {
        switch self {
        case .U, .EPrime, .DPrime:
            return (x: -coord.z, y: coord.y, z: coord.x)
        case .D, .E, .UPrime:
            return CubeMove.U.rotateCoordinate((-coord.x, coord.y, -coord.z))
        case .R, .MPrime, .LPrime:
            return (x: coord.x, y: coord.z, z: -coord.y)
        case .L, .M, .RPrime:
            return CubeMove.R.rotateCoordinate((coord.x, -coord.y, -coord.z))
        case .F, .S, .BPrime:
            return (x: coord.y, y: -coord.x, z: coord.z)
        case .B, .SPrime, .FPrime:
            return CubeMove.F.rotateCoordinate((-coord.x, -coord.y, coord.z))
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
        case .S: return .SPrime
        case .SPrime: return .S
        case .E: return .EPrime
        case .EPrime: return .E
        }
    }
}

// MARK: – CubeManager
class CubeManager: ObservableObject {
    let scene: SCNScene
    let cubeContainer: SCNNode   // Container node for the entire cube
    var cubies: [Cubie] = []
    let offset: Float = 0.97
    var moveHistory: [CubeMove] = []
    var isAnimating = false
    var unscrambleTimer: Timer?
    
    let size: Float = 5
    let chamfer: CGFloat = 0.1
    
    init(moves: [CubeMove]) {
        scene = SCNScene()
        cubeContainer = SCNNode()
        let cubeParent = SCNNode()
        cubeParent.addChildNode(cubeContainer)
        let secondParent = SCNNode()
        secondParent.addChildNode(cubeParent)
        scene.rootNode.addChildNode(secondParent)
        cubeContainer.rotation = .init(x: 0, y: 1, z: 0, w: .pi / 4.0)
        cubeParent.rotation = .init(x: 1, y: 0, z: 0, w: .pi / 4.0)
//        scene.background.contents = UIColor.blue
        buildCube()
        setupCameraAndLights()
        performMoves(moves, animated: false)
//        doRotate()
    }
    
    func doRotate() {
        let rotationAction = SCNAction.rotate(
            by: 2.0 * .pi,
            around: .init(x: 1, y: 0, z: 0),
            duration: 3
        )
        
        cubeContainer.parent?.runAction(rotationAction) {
            self.doRotate()
        }
    }
    
    private func setupCameraAndLights() {
        // Set up the camera at (7,7,7) with a look-at constraint.
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        let distance = 5.5 * size
        cameraNode.position = SCNVector3(0, 1, distance)
        let constraint = SCNLookAtConstraint(target: cubeContainer)
//        constraint.isGimbalLockEnabled = true
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
    
    private func material(with color: UIColor) -> SCNMaterial {
        let material = SCNMaterial()
        let layer = CubeStickerLayer(color: color)
        layer.frame = .init(origin: .zero, size: .init(width: 100, height: 100))
        layer.display()
        material.diffuse.contents = layer
        material.locksAmbientWithDiffuse = true
        material.ambient.contents = UIColor.white
        return material
    }
    
    private func buildCube() {
        // Build the 3×3×3 cube with a chamfer.
        let colors: [UIColor] = [.red, .blue, .orange, .green, .white, .yellow]
        
        for x in -1...1 {
            for y in -1...1 {
                for z in -1...1 {
                    let box = SCNBox(
                        width: CGFloat(size),
                        height: CGFloat(size),
                        length: CGFloat(size),
                        chamferRadius: chamfer * CGFloat(size)
                    )
                    box.materials = colors.map { material(with: $0) }
                    
                    let cubieNode = SCNNode(geometry: box)
                    cubieNode.position = SCNVector3(Float(x) * offset * size,
                                                    Float(y) * offset * size,
                                                    Float(z) * offset * size) + box.offsetForSize
                    cubeContainer.addChildNode(cubieNode)
                    let cubie = Cubie(node: cubieNode, position: (x, y, z))
                    cubies.append(cubie)
                }
            }
        }
    }
    
    private func updateCubieTransform(_ cubie: Cubie) {
        guard let box = cubie.node.geometry as? SCNBox else { return }
        let newPos = SCNVector3(Float(cubie.logicalPosition.x) * offset * size,
                                Float(cubie.logicalPosition.y) * offset * size,
                                Float(cubie.logicalPosition.z) * offset * size) + box.offsetForSize
        cubie.node.position = newPos
        cubie.node.orientation = cubie.netRotation
    }
    
    // MARK: – Move Execution
    @MainActor
    func performMove(_ move: CubeMove, record: Bool = true, duration: Double) async {
        guard !isAnimating else { return }
        isAnimating = true
        
        let affectedCubies = affectedCubies(for: move.affectedLayer)
        
        let groupNode = SCNNode()
        cubeContainer.addChildNode(groupNode)
        for cubie in affectedCubies {
            cubie.node.removeFromParentNode()
            groupNode.addChildNode(cubie.node)
        }
        
        let rotationAction = SCNAction.rotate(
            by: CGFloat(move.angle),
            around: move.axis, duration: duration
        )
        
        await groupNode.runAction(rotationAction)
        
        updateCubies(with: affectedCubies, for: move)
        
        groupNode.removeFromParentNode()
        if record { self.moveHistory.append(move) }
        self.isAnimating = false
    }
    
    private func affectedCubies(for layer: (axis: String, value: Int)) -> [Cubie] {
        cubies.filter { cubie in
            switch layer.axis {
            case "x": return cubie.logicalPosition.x == layer.value
            case "y": return cubie.logicalPosition.y == layer.value
            case "z": return cubie.logicalPosition.z == layer.value
            default: return false
            }
        }
    }
    
    private func updateCubies(with affectedCubies: [Cubie], for move: CubeMove) {
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
    }
    
    private func multiplyQuaternion(q1: SCNQuaternion, q2: SCNQuaternion) -> SCNQuaternion {
        q1 * q2
    }
    
    // MARK: – Scramble & Solve
    func performMoves(_ moves: [CubeMove], animated: Bool) {
        Task {
            for move in moves {
                if animated {
                    await performMove(move, duration: 0.1)
                } else {
                    updateCubies(with: affectedCubies(for: move.affectedLayer), for: move)
                }
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

extension SCNBox {
    var offsetForSize: SCNVector3 {
        .init(0, 0, 0)
    }
}

class CubeStickerLayer: CALayer {
    let color: UIColor
    
    init(color: UIColor) {
        self.color = color
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var sizingLength: CGFloat {
        max(bounds.height, bounds.width)
    }
    
    var insetRatio: CGFloat {
        0.05
    }
    
    var inset: CGFloat {
        sizingLength * insetRatio
    }
    
    var cornerSize: CGFloat {
        (0.2 - insetRatio) * sizingLength
    }
    
    override func draw(in ctx: CGContext) {
        ctx.setFillColor(UIColor.black.cgColor)
        ctx.fill(bounds)
        ctx.addPath(.init(
            roundedRect: bounds.insetBy(dx: inset, dy: inset),
            cornerWidth: cornerSize, cornerHeight: cornerSize,
            transform: nil)
        )
        ctx.setFillColor(color.cgColor)
        ctx.fillPath()
    }
}
