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
  
  func calculateAngularVelocity(angularVelocity: CGFloat) -> CGFloat {
    var aVelocity = angularVelocity
    if isClockwise {
      if angularVelocity > 0 || angularVelocity < -π/6*4{
        aVelocity = 0
      }
    }else {
      if angularVelocity < 0 || angularVelocity > π/6*4 {
        aVelocity = 0
      }
    }
    return aVelocity
  }
  
}
