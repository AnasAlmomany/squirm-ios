//
//  Copyright © 2018 Carl Ekman. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String: GKGraph]()

    private var rng: GKRandomDistribution!
    private var lastUpdateTime: TimeInterval = 0
    private var score: Int = 0

    private var foodCounter: Int = 0
    private var foodTime: Int = 100
    private var foodNode: SKShapeNode?

    private var wormNodes: [SKShapeNode] = []
    private var headNode: SKShapeNode? {
        let count = self.wormNodes.count
        return count > 0 ? self.wormNodes[0] : nil
    }
    private var tailNode: SKShapeNode? {
        let count = self.wormNodes.count
        return count > 0 ? self.wormNodes[count - 1] : nil
    }

    private var startNodes: Int = 10
    private let nodeDiameter: CGFloat = 20.0
    private let speedFactor: CGFloat = 5.0
    private let turnFactor: CGFloat = 7.0

    private var direction: Direction = .neutral
    private var degrees: Int = 90 {
        didSet { degrees = degrees % 360 }
    }

    // MARK: - Lifecycle

    override func sceneDidLoad() {
        self.rng = GKRandomDistribution(lowestValue: 0, highestValue: 150)

        let node = self.node(for: CGPoint.zero)
        self.wormNodes.append(node)
        self.addChild(node)
    }

    // MARK: - Logic

    private var radians: CGFloat {
        get { return CGFloat(self.degrees) * CGFloat.pi / 180 }
    }

    private func direction(for pointInSelf: CGPoint) -> Direction {
        //guard abs(pointInSelf.x) > 20 else { return .neutral }

        return pointInSelf.x < 0 ? .counterClockwise : .clockwise
    }

    private var nextPosition: CGPoint {
        let x = cos(self.radians) * self.speedFactor
        let y = sin(self.radians) * self.speedFactor

        return CGPoint(x: x, y: y)
    }

    private func node(for position: CGPoint) -> SKShapeNode {
        let d = self.nodeDiameter
        let node = SKShapeNode(ellipseOf: CGSize(width: d, height: d))
        node.position = position
        node.fillColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

        return node
    }

    private func wormCollides(with pos: CGPoint, ignoringFirst ignored: Int = 0, tolerance t: CGFloat = 0) -> Bool {
        let r = self.nodeDiameter / 2
        var nodes = self.wormNodes
        for _ in 0..<ignored {
            nodes = Array(nodes.dropFirst())
        }
        for n in nodes {
            if n.position.collides(with: pos, tolerance: r + t) {
                return true
            }
        }

        return false
    }

    // MARK: - Touch Events
    
    func touchDown(atPoint pos: CGPoint) {
        self.direction = self.direction(for: pos)
    }
    
    func touchMoved(toPoint pos: CGPoint) {
        self.direction = self.direction(for: pos)
    }
    
    func touchUp(atPoint pos: CGPoint) {
        self.direction = .neutral
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }

    // MARK: - Game Loop
    
    override func update(_ currentTime: TimeInterval) {
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        let dt = currentTime - self.lastUpdateTime

        self.checkGrowth()
        self.checkCollision()
        self.incrementFood()
        self.incrementAngle()
        self.moveNodes(time: dt)

        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }

    private func incrementAngle() {
        switch self.direction {
        case .clockwise:
            self.degrees = self.degrees - Int(self.turnFactor)
        case .counterClockwise:
            self.degrees = self.degrees + Int(self.turnFactor)
        case .neutral:
            break
        }
    }

    private func incrementFood() {
        guard self.foodNode == nil else { return }

        self.foodCounter = self.foodCounter + 1

        if self.foodCounter >= self.foodTime {
            self.foodCounter = 0

            var spawn = CGPoint.zero
            repeat {
                let randX = self.rng.nextInt()
                let randY = self.rng.nextInt()
                spawn = CGPoint(x: randX, y: randY) // Currenty only spawns within 150x150

            } while self.wormCollides(with: spawn, tolerance: 10)

            let node = self.node(for: spawn)
            self.foodNode = node
            self.addChild(node)
            node.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut") // FIXME: Animation
        }
    }

    private func incrementScore() {
        // TODO: Animate head node
        self.foodNode?.removeFromParent()
        self.foodNode = nil
        self.foodCounter = 0
        self.score = self.score + 5
    }

    private func checkGrowth() {
        let diff = self.score + self.startNodes - self.wormNodes.count
        guard diff > 0, let tail = self.tailNode else { return }

        let node = self.node(for: tail.position)
        self.wormNodes.append(node)
        self.addChild(node) // FIXME: Place under or make worm one single node?
    }

    private func moveNodes(time: TimeInterval) {
        let nodes = self.wormNodes

        for (i, node) in nodes.enumerated() {
            if i > 0 {
                // Move body node
                let prev = nodes[i - 1]
                let pos = prev.position
                let move = SKAction.move(to: pos, duration: time)
                move.timingMode = SKActionTimingMode.linear
                node.run(move)
            } else {
                // Move head node
                let pos = self.nextPosition
                let move = SKAction.moveBy(x: pos.x, y: pos.y, duration: time)
                move.timingMode = SKActionTimingMode.linear
                node.run(move)
            }
        }
    }

    private func checkCollision() {
        guard let n = self.headNode else { return }
        let r = self.nodeDiameter / 2

        // Check edges
        if abs(n.position.x) > (self.size.width / 2) - r ||
           abs(n.position.y) > (self.size.height / 2) - r {
            self.gameOver()
        }

        // Check body
        if self.wormCollides(with: n.position, ignoringFirst: self.startNodes, tolerance: 0) {
            self.gameOver()
        }

        // Check food
        guard let f = self.foodNode else { return }
        if self.wormCollides(with: f.position, tolerance: self.nodeDiameter - 2) {
            self.incrementScore()
        }
    }

    private func gameOver() {
        let bodyNodes = Array(self.wormNodes.dropFirst())
        for n in bodyNodes {
            n.removeFromParent()
        }

        self.headNode?.position = CGPoint(x: 0, y: 0)
        self.wormNodes = [self.headNode!]
    }
}

// MARK: - Structs

fileprivate enum Direction {

    case neutral
    case clockwise
    case counterClockwise
}

// MARK: - Extensions

fileprivate extension CGPoint {

    func collides(with p: CGPoint, tolerance t: CGFloat = 0) -> Bool {
        return abs(self.x - p.x) < t && abs(self.y - p.y) < t
    }
}