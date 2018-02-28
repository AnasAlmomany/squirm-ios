//
//  Copyright © 2018 Carl Ekman. All rights reserved.
//

import Foundation
import SpriteKit

struct NodeFactory {

    /// Returns a SKShapeNode from a CGPath generated form the given points.
    static func pathNode(for points: [CGPoint]) -> SKShapeNode? {
        guard let head = points.first else { return nil }

        let path = UIBezierPath()
        path.move(to: head)
        for p in points.dropFirst() {
            path.addLine(to: p)
        }

        let node = SKShapeNode(path: path.cgPath)
        node.lineWidth = Constants.nodeDiameter
        node.lineCap = .round
        node.lineJoin = .round
        node.strokeColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

        return node
    }

    /// Returns a simple SKShapeNode for the given point.
    static func node(for point: CGPoint) -> SKShapeNode {
        let d = Constants.nodeDiameter
        let node = SKShapeNode(ellipseOf: CGSize(width: d, height: d))
        node.position = point
        node.fillColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

        return node
    }
}
