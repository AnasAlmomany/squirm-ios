//
//  Copyright © 2018 Carl Ekman. All rights reserved.
//

import Foundation
import SpriteKit

struct Worm {

    var nodes: [SKShapeNode] = []

    subscript(index: Int) -> SKShapeNode {
        return self.nodes[index]
    }

    var count: Int {
        return self.nodes.count
    }

    var head: SKShapeNode? {
        return self.count > 0 ? self[0] : nil
    }

    var tail: SKShapeNode? {
        return self.count > 0 ? self[self.count - 1] : nil
    }
}
