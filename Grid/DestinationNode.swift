//
//  DestinationNode.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/12.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit

class DestinationNode: SKSpriteNode, CustomNodeEvents {
  
  // CustomNodeEvents Method
  func didMoveToScene() {
    physicsBody = SKPhysicsBody(circleOfRadius: size.width/2.0)
    
    physicsBody!.dynamic = false
    physicsBody!.categoryBitMask = PhysicsCategory.Distance
    physicsBody!.collisionBitMask = PhysicsCategory.None
    physicsBody!.contactTestBitMask = PhysicsCategory.Ball
    
    zPosition = 0
  }
}
