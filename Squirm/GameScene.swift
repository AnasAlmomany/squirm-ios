//
//  Copyright © 2018 Carl Ekman. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String: GKGraph]()

    private var worm: Worm!
    private var control: GameControl!
    private var rng: GKRandomDistribution!

    private var lastUpdateTime: TimeInterval = 0
    private var score: Int = 0

    private var foodCounter: Int = 0
    private var foodNode: SKShapeNode?

    // MARK: - Lifecycle

    override func sceneDidLoad() {
        self.worm = Worm()
        self.control = GameControl()
        self.rng = GKRandomDistribution(lowestValue: 0, highestValue: 150)
        self.addWormNode(for: CGPoint.zero)
    }

    // MARK: - Computed Properties

    private func node(for position: CGPoint) -> SKShapeNode {
        let d = Constants.nodeDiameter
        let node = SKShapeNode(ellipseOf: CGSize(width: d, height: d))
        node.position = position
        node.fillColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

        return node
    }

    private func addWormNode(for position: CGPoint) {
        let node = self.node(for: position)
        self.worm.nodes.append(node)
        self.addChild(node)
    }

    // MARK: - Logic

    private func wormCollides(with pos: CGPoint, ignoringFirst ignored: Int = 0, tolerance t: CGFloat = 0) -> Bool {
        let r = Constants.nodeDiameter / 2
        var nodes = self.worm.nodes
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
    
    func touch(atPoint pos: CGPoint) {
        let bounds = Constants.controlBounds
        self.control.input = max(min(pos.x / bounds, bounds), -bounds)
    }
    
    func touchUp(atPoint pos: CGPoint) {
        self.control.input = 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.control.oscillation = 0
        for t in touches { self.touch(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touch(atPoint: t.location(in: self)) }
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
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        self.lastUpdateTime = currentTime

        self.checkGrowth()
        self.checkCollision()
        self.moveNodes()
        self.incrementFood()
        self.incrementAngle()
    }

    // MARK: Loop logic

    private func checkGrowth() {
        let diff = self.score + Constants.startNodes - self.worm.count

        guard diff > 0, let tail = self.worm.tail else { return }

        self.addWormNode(for: tail.position)
    }

    private func checkCollision() {
        guard let n = self.worm.head else { return }
        let r = Constants.nodeDiameter / 2

        // Check edges
        if abs(n.position.x) > (self.size.width / 2) - r ||
            abs(n.position.y) > (self.size.height / 2) - r {
            self.gameOver()
        }

        // Check body
        if self.wormCollides(with: n.position, ignoringFirst: Constants.startNodes, tolerance: 0) {
            self.gameOver()
        }

        // Check food
        guard let f = self.foodNode else { return }
        if self.wormCollides(with: f.position, tolerance: Constants.nodeDiameter / 2) {
            self.incrementScore()
        }
    }

    private func moveNodes() {
        // Move tail to new head index
        let headPos = self.worm.head!.position
        let newHead = self.worm.tail!
        self.worm.nodes = Array(self.worm.nodes.dropLast())
        self.worm.nodes.insert(newHead, at: 0)

        // Move new head
        self.worm.head!.position = headPos.movedBy(coordinates: self.control.nextPosition)
    }

    private func incrementFood() {
        guard self.foodNode == nil else { return }

        self.foodCounter += 1
        if self.foodCounter >= Constants.foodTime {
            self.foodCounter = 0

            var spawn = CGPoint.zero
            repeat {
                let randX = self.rng.nextInt()
                let randY = self.rng.nextInt()
                spawn = CGPoint(x: randX, y: randY) // Currenty only spawns within 150x150

            } while self.wormCollides(with: spawn, tolerance: 20)

            let node = self.node(for: spawn)
            self.foodNode = node
            self.addChild(node)
            node.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut") // FIXME: Animation
        }
    }

    private func incrementAngle() {
        self.control.respondToInput()
    }

    private func incrementScore() {
        self.foodNode?.removeFromParent()
        self.foodNode = nil
        self.foodCounter = 0
        self.score += Constants.scoreIncrement
    }

    private func gameOver() {
        let bodyNodes = Array(self.worm.nodes.dropFirst())
        for n in bodyNodes {
            n.removeFromParent()
        }

        self.worm.head!.position = CGPoint.zero
        self.worm.nodes = [self.worm.head!]
        self.score = 0
    }
}
