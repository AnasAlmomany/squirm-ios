//
//  Copyright © 2018 Carl Ekman. All rights reserved.
//

import Foundation
import UIKit

extension ClosedRange {

    func clamp(_ value: Bound) -> Bound {
        return self.lowerBound > value ? self.lowerBound
             : self.upperBound < value ? self.upperBound
             : value
    }
}

extension CGPoint {

    func collides(with p: CGPoint, tolerance t: CGFloat = 0) -> Bool {
        return abs(self.x - p.x) < t && abs(self.y - p.y) < t
    }

    func movedBy(coordinates c: CGPoint) -> CGPoint {
        return CGPoint(x: self.x + c.x, y: self.y + c.y)
    }
}
