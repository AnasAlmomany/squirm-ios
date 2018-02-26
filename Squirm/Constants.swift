//
//  Copyright © 2018 Carl Ekman. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    private init() {}

    static let scoreIncrement: Int = 5          // Base score increment (points)
    static let startNodes: Int = 10             // Starting length (nodes)
    static let nodeDiameter: CGFloat = 20.0     // Node size (pts)

    static let foodTime: Int = 100              // Spawn time for food (frames)

    static let speedFactor: CGFloat = 4.0       // Movement (frames)
    static let turnFactor: CGFloat = 6.0        // Turn radius (pts)
    static let accelerationRate: CGFloat = 0.1  // Turn acceleration rate (ratio)
    static let oscillationRate: CGFloat = 0.05  // Neutral oscillation rate (cycles per frame)
    static let controlBounds: CGFloat = 200.0   // Bounds for min/max x-axis control input (pts)
    
    static let oscillate: Bool = true           // True for oscillation while neutral
    static let dynamicControl: Bool = true      // True for gradual x-axis control input
}
