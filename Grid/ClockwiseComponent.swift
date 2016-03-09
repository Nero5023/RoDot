//
//  ClockwiseComponent.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/9.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

class ClockwiseComponent: GKComponent {
  
  // MARK: Properties
  
  var isClockwise: Bool
  
  // MARK: Initializers
  
  init(isClockwise: Bool) {
    self.isClockwise = isClockwise
    super.init()
  }
  
  func calculateAngularVelocity(var angularVelocity: CGFloat) -> CGFloat {
    if isClockwise {
      if angularVelocity > 0 || angularVelocity < -π/6*4{
        angularVelocity = 0
      }
    }else {
      if angularVelocity < 0 || angularVelocity > π/6*4 {
        angularVelocity = 0
      }
    }
    return angularVelocity
  }
  
}
