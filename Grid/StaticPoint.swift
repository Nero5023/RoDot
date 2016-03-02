//
//  StaticPoint.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/1.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

class StaticPoint: BasePointEntity {
  
  // Mark: Initializers
  
  override init(renderNode: SKSpriteNode) {
    super.init(renderNode: renderNode)
    
    let intelligenceComponent = IntelligenceComponent(states: [PointLockedForeverState(entity: self)])
    addComponent(intelligenceComponent)
  }
  
}
