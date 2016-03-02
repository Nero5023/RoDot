//
//  RotationPoint.swift
//  Grid
//
//  Created by Nero Zuo on 16/2/24.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

class RotationPoint: BasePointEntity {
  // Mark: properties
  
  // Mark: Initializers
  
  override init(renderNode: SKSpriteNode) {
    super.init(renderNode: renderNode)
    
    let relateComponent = RelateComponent()
    addComponent(relateComponent)
    
    let intelligenceComponent = IntelligenceComponent(states: [
      PointCheckingState(entity: self),
      PointUnlockedState(entity: self),
      PointLockedState(entity: self),
      PointRotatingState(entity: self)
    ])
    addComponent(intelligenceComponent)
    
    let detectComponent = DetectComponent()
    addComponent(detectComponent)
    
    let moveComponent = MoveComponent()
    addComponent(moveComponent)
    
  }
}
