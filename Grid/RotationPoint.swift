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
  
  init(renderNode: SKSpriteNode, rotateCount: Int?) {
    super.init(renderNode: renderNode)
    
    let relateComponent = RelateComponent()
    addComponent(relateComponent)
    
    if let rotateCount = rotateCount {
      let intelligenceComponent = IntelligenceComponent(states: [
        PointCheckingState(entity: self),
        PointUnlockedState(entity: self),
        PointLockedState(entity: self),
        PointRotatingState(entity: self),
        PointLockedForeverState(entity: self)
        ])
      addComponent(intelligenceComponent)
      let rotateCountComponent = RotateCountComponent(rotateCount: rotateCount)
      addComponent(rotateCountComponent)
    }else {
      let intelligenceComponent = IntelligenceComponent(states: [
        PointCheckingState(entity: self),
        PointUnlockedState(entity: self),
        PointLockedState(entity: self),
        PointRotatingState(entity: self)
        ])
      addComponent(intelligenceComponent)
    }
    
    
    let detectComponent = DetectComponent()
    addComponent(detectComponent)
    
    let moveComponent = MoveComponent()
    addComponent(moveComponent)
    
  }
}
