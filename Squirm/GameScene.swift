//
//  Copyright © 2018 Carl Ekman. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String: GKGraph]()

    private var wormNode: SKShapeNode?
    private var worm: Worm!
    private var control: GameControl!
    private var rng: GKRandomDistribution!

    private var foodNode: SKShapeNode?
    private var foodCounter: Int = 0

    private var lastUpdateTime: TimeInterval = 0
    private var score: Int = 0

    // MARK: - Lifecycle

    override func sceneDidLoad() {
        self.worm = Worm()
        self.control = GameControl()
        self.rng = GKRandomDistribution(lowestValue: 0, highestValue: 150)
        self.worm.points.append(CGPoint.zero)
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

        self.movePoints()
        self.drawWorm()

        self.incrementFood()
        self.incrementAngle()
    }

    // MARK: Loop logic

    private func checkGrowth() {
        let diff = self.score + Constants.startNodes - self.worm.count
        guard diff > 0, let tail = self.worm.tail else { return }

        self.worm.points.append(tail)
    }

    private func checkCollision() {
        guard let n = self.worm.head else { return }
        let r = Constants.nodeDiameter / 2

        // Check edges
        if abs(n.x) > (self.size.width / 2) - r ||
            abs(n.y) > (self.size.height / 2) - r {
            self.gameOver()
        }

        // Check body
        if self.worm.collides(with: n, ignoringFirst: Constants.startNodes, tolerance: 0) {
            self.gameOver()
        }

        // Check food
        guard let f = self.foodNode else { return }
        if self.worm.collides(with: f.position, tolerance: Constants.nodeDiameter / 2) {
            self.incrementScore()
        }
    }

    private func movePoints() {
        guard let head = self.worm.head else { return }

        self.worm.points = Array(self.worm.points.dropLast())
        self.worm.points.insert(head.movedBy(coordinates: self.control.nextPosition), at: 0)
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

            } while self.worm.collides(with: spawn, tolerance: 20)

            let node = NodeFactory.node(for: spawn)
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

    private func drawWorm() {
        guard let node = NodeFactory.pathNode(for: self.worm.points) else { return }
        self.wormNode?.removeFromParent()
        self.wormNode = node
        self.addChild(node)
    }

    private func gameOver() {
        self.wormNode?.removeFromParent()
        self.worm.points = [CGPoint.zero]

        self.foodNode?.removeFromParent()
        self.foodNode = nil

        self.foodCounter = 0
        self.score = 0
    }
}
