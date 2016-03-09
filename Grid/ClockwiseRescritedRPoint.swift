//
//  ClockwiseRescritedRPoint.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/9.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

class ClockwiseRescritedRPoint: RestrictedRotationPoint {
  // Mark: properties
  
  // Mark: Initializers
  
  init(renderNode: SKSpriteNode, rotatableRodCount: Int, isClockwise: Bool) {
    super.init(renderNode: renderNode, rotatableRodCount: rotatableRodCount)
    
    let clockwiseComponent = ClockwiseComponent(isClockwise: isClockwise)
    addComponent(clockwiseComponent)
  }
}
