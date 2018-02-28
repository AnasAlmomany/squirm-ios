//
//  Copyright © 2018 Carl Ekman. All rights reserved.
//

import Foundation
import SpriteKit

struct Worm {

    var points: [CGPoint] = []

    subscript(index: Int) -> CGPoint {
        return self.points[index]
    }

    var count: Int {
        return self.points.count
    }

    var head: CGPoint? {
        return self.count > 0 ? self[0] : nil
    }

    var tail: CGPoint? {
        return self.count > 0 ? self[self.count - 1] : nil
    }

    func collides(with pos: CGPoint, ignoringFirst ignored: Int = 0, tolerance t: CGFloat = 0) -> Bool {
        let r = Constants.nodeDiameter / 2
        var points = self.points
        for _ in 0..<ignored {
            points = Array(points.dropFirst())
        }
        for p in points {
            if p.collides(with: pos, tolerance: r + t) {
                return true
            }
        }
        return false
    }
}
