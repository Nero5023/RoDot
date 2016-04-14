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
    physicsBody = SKPhysicsBody(circleOfRadius: size.width/6.0)
    
    physicsBody!.dynamic = false
    physicsBody!.categoryBitMask = PhysicsCategory.Distance
    physicsBody!.collisionBitMask = PhysicsCategory.None
    physicsBody!.contactTestBitMask = PhysicsCategory.Ball
    
    zPosition = 0

    alpha = 0
    runAction(SKAction.sequence([SKAction.waitForDuration(1), SKAction.fadeInWithDuration(0.66)]))
  }
}
