//
//  TransferNode.swift
//  Grid
//
//  Created by Nero Zuo on 16/2/21.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit

class TransferNode: SKSpriteNode, CustomNodeEvents {
  
  func didMoveToScene() {
    physicsBody = SKPhysicsBody(circleOfRadius: size.width/10)
    
    physicsBody!.dynamic = false
    physicsBody!.categoryBitMask = PhysicsCategory.Transfer
    physicsBody!.collisionBitMask = PhysicsCategory.None
    physicsBody!.contactTestBitMask = PhysicsCategory.Ball
  }
}
