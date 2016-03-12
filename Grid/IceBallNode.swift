//
//  IceBallNode.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/9.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

class IceBallNode: SKSpriteNode, CustomNodeEvents  {
  
  func didMoveToScene() {
    physicsBody = SKPhysicsBody(circleOfRadius: size.width/2)
    
    physicsBody!.categoryBitMask = PhysicsCategory.IceBall
    physicsBody!.collisionBitMask = PhysicsCategory.Rod | PhysicsCategory.PointNode | PhysicsCategory.Edge | PhysicsCategory.Ball | PhysicsCategory.IceBall
    physicsBody!.contactTestBitMask = PhysicsCategory.Transfer
    physicsBody!.mass = 0.015
    //    physicsBody!.allowsRotation = false
    zPosition = 1000
  }
}
