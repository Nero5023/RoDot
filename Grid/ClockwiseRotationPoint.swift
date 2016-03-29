//
//  ClockwiseRotationPoint.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/9.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

class ClockwiseRotationPoint: RotationPoint {
  // Mark: properties
  
  // Mark: Initializers
  
  init(renderNode: SKSpriteNode, isClockwise: Bool, rotateCount: Int?) {
    super.init(renderNode: renderNode, rotateCount: rotateCount)
    
    let clockwiseComponent = ClockwiseComponent(isClockwise: isClockwise)
    addComponent(clockwiseComponent)
//    clockwiseComponent.animationBubble()
  }
}
