//
//  Copyright © 2018 Carl Ekman. All rights reserved.
//

import Foundation
import UIKit

struct GameControl {

    var degrees: Int = 90 {
        didSet { degrees = degrees % 360 }
    }

    var oscillation: Int = 0 {
        didSet { oscillation = oscillation % 360 }
    }

    var acceleration: CGFloat = 0.0 {
        didSet { acceleration = (-1.0...1.0).clamp(acceleration) }
    }

    var input: CGFloat = 0.0 {
        didSet { input = (-1.0...1.0).clamp(input) }
    }

    // MARK: - Computed

    var nextPosition: CGPoint {
        let x = cos(self.degrees.asRadians) * Constants.speedFactor
        let y = sin(self.degrees.asRadians) * Constants.speedFactor

        return CGPoint(x: x, y: y)
    }

    // MARK: - Functions

    mutating func respondToInput() {
        var modifier: Int = 0

        let turn    = Constants.turnFactor
        let accRate = Constants.accelerationRate
        let oscRate = Int(Constants.oscillationRate * 360)

        if abs(self.input) > 0.1 {
            let controlFactor = Constants.dynamicControl ? abs(self.input) : 1
            let turnFactor = Constants.dynamicControl ? turn * 1.5 : turn

            self.acceleration += input < 0 ? accRate : -accRate
            modifier = Int(self.acceleration * turnFactor * controlFactor)

        } else {
            // Oscillate
            if Constants.oscillate {
                self.oscillation += oscRate
                modifier = Int((turn / 2) * sin(self.oscillation.asRadians))
            }
            // Decelerate
            if (-accRate...accRate).contains(self.acceleration) {
                self.acceleration = 0
            } else if self.acceleration >= accRate {
                self.acceleration -= accRate
            } else if self.acceleration <= -accRate {
                self.acceleration += accRate
            }
        }

        self.degrees += modifier
    }
}
